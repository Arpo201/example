#!/usr/bin/env python3
"""
Kubernetes Namespace vs ArgoCD AppProject Validator

Compares actual K8s namespaces with ArgoCD AppProject destination configurations
to identify coverage gaps and unused patterns.

Usage:
    python main.py --kubeconfig ~/.kube/sandbox-th --context my-context --cluster-name sandbox-th --appproject-dir /path/to/appprojects
"""

import argparse
import json
import re
import subprocess
import sys
import yaml
from pathlib import Path


def get_k8s_namespaces(kubeconfig, context):
    """Fetch all namespaces from K8s cluster"""
    cmd = ["kubectl", "get", "namespaces", "-o", "json"]
    if kubeconfig:
        cmd.extend(["--kubeconfig", kubeconfig])
    if context:
        cmd.extend(["--context", context])
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        data = json.loads(result.stdout)
        return sorted([item['metadata']['name'] for item in data['items']])
    except subprocess.CalledProcessError as e:
        print(f"\033[91m❌ Error fetching namespaces: {e.stderr}\033[0m")
        sys.exit(1)


def parse_appprojects(appproject_dir, cluster_name):
    """Parse AppProject YAML files and extract destinations for specific cluster"""
    appproject_dir = Path(appproject_dir)
    destinations = {}
    
    for yaml_file in appproject_dir.glob("*.yaml"):
        try:
            with open(yaml_file) as f:
                docs = yaml.safe_load_all(f)
                for doc in docs:
                    if doc and doc.get('kind') == 'AppProject':
                        project_name = doc['metadata']['name']
                        dest_list = []
                        
                        for dest in doc['spec'].get('destinations', []):
                            if dest.get('name') == cluster_name:
                                dest_list.append(dest['namespace'])
                        
                        destinations[project_name] = dest_list
        except Exception as e:
            print(f"\033[93m⚠️  Error parsing {yaml_file}: {e}\033[0m")
    
    return destinations


def matches_pattern(namespace, pattern):
    """Check if namespace matches a pattern (supports wildcards)"""
    if '*' in pattern:
        regex = '^' + pattern.replace('*', '.*') + '$'
        return bool(re.match(regex, namespace))
    return namespace == pattern


def get_matching_namespaces(k8s_ns_list, patterns):
    """Get all k8s namespaces that match any of the patterns"""
    matched = set()
    for ns in k8s_ns_list:
        for pattern in patterns:
            if matches_pattern(ns, pattern):
                matched.add(ns)
                break
    return matched


def print_report(k8s_namespaces, appproject_destinations):
    """Print colorful comparison report"""
    all_patterns = set()
    for patterns in appproject_destinations.values():
        all_patterns.update(patterns)
    
    matched_namespaces = get_matching_namespaces(k8s_namespaces, all_patterns)
    not_in_appprojects = set(k8s_namespaces) - matched_namespaces
    
    patterns_without_match = [
        p for p in all_patterns 
        if not any(matches_pattern(ns, p) for ns in k8s_namespaces)
    ]
    
    print("\033[1m\033[96m" + "="*80 + "\033[0m")
    print("\033[1m\033[94m📊 NAMESPACE COMPARISON REPORT\033[0m")
    print("\033[1m\033[96m" + "="*80 + "\033[0m\n")
    
    print(f"\033[1m\033[92m✅ K8s Namespaces (Total: {len(k8s_namespaces)})\033[0m")
    print("\033[96m" + "-"*80 + "\033[0m")
    for ns in k8s_namespaces:
        print(f"  • {ns}")
    
    print("\n\033[1m\033[95m📋 AppProject Destinations by Project\033[0m")
    print("\033[96m" + "-"*80 + "\033[0m")
    for project, patterns in sorted(appproject_destinations.items()):
        print(f"\n  \033[1m{project}:\033[0m")
        if not patterns:
            print(f"    \033[93m⚠️  No destinations configured\033[0m")
        else:
            for pattern in patterns:
                matching = [ns for ns in k8s_namespaces if matches_pattern(ns, pattern)]
                if matching:
                    print(f"    • {pattern} \033[92m→ matches {len(matching)} namespace(s)\033[0m")
                else:
                    print(f"    • {pattern} \033[93m→ no matches\033[0m")
    
    print(f"\n\033[1m\033[92m✅ Namespaces Covered by AppProjects (Total: {len(matched_namespaces)})\033[0m")
    print("\033[96m" + "-"*80 + "\033[0m")
    if matched_namespaces:
        for ns in sorted(matched_namespaces):
            covering_projects = [
                p for p, pats in appproject_destinations.items()
                if any(matches_pattern(ns, pat) for pat in pats)
            ]
            print(f"  • {ns} \033[90m[{', '.join(covering_projects)}]\033[0m")
    else:
        print("  \033[93m⚠️  No namespaces covered\033[0m")
    
    if not_in_appprojects:
        print(f"\n\033[1m\033[91m❌ Namespaces NOT Covered by AppProjects (Total: {len(not_in_appprojects)})\033[0m")
        print("\033[96m" + "-"*80 + "\033[0m")
        for ns in sorted(not_in_appprojects):
            print(f"  • {ns}")
    else:
        print("\n\033[1m\033[92m✅ All namespaces are covered by AppProjects!\033[0m")
    
    if patterns_without_match:
        print(f"\n\033[1m\033[93m⚠️  AppProject Patterns Without Matches (Total: {len(patterns_without_match)})\033[0m")
        print("\033[96m" + "-"*80 + "\033[0m")
        for pattern in sorted(patterns_without_match):
            projects = [p for p, pats in appproject_destinations.items() if pattern in pats]
            print(f"  • {pattern} \033[90m[{', '.join(projects)}]\033[0m")
    
    print("\n\033[1m\033[96m" + "="*80 + "\033[0m")
    print("\033[1m\033[94m📈 SUMMARY\033[0m")
    print("\033[1m\033[96m" + "="*80 + "\033[0m")
    print(f"  Total K8s Namespaces:              \033[1m{len(k8s_namespaces)}\033[0m")
    print(f"  Covered by AppProjects:            \033[92m{len(matched_namespaces)}\033[0m")
    print(f"  NOT Covered by AppProjects:        \033[91m{len(not_in_appprojects)}\033[0m")
    print(f"  AppProject Patterns (Total):       \033[1m{len(all_patterns)}\033[0m")
    print(f"  Patterns Without Matches:          \033[93m{len(patterns_without_match)}\033[0m")
    print("\033[1m\033[96m" + "="*80 + "\033[0m\n")


def main():
    parser = argparse.ArgumentParser(
        description='Validate K8s namespaces against ArgoCD AppProject destinations'
    )
    parser.add_argument('--kubeconfig', help='Path to kubeconfig file')
    parser.add_argument('--context', help='Kubernetes context to use')
    parser.add_argument('--cluster-name', required=True, 
                       help='Cluster name to match in AppProject destinations (e.g., sandbox-th)')
    parser.add_argument('--appproject-dir', required=True,
                       help='Directory containing AppProject YAML files')
    
    args = parser.parse_args()
    
    print("\033[94m🔍 Fetching K8s namespaces...\033[0m")
    k8s_namespaces = get_k8s_namespaces(args.kubeconfig, args.context)
    
    print(f"\033[94m📂 Parsing AppProjects from {args.appproject_dir}...\033[0m")
    appproject_destinations = parse_appprojects(args.appproject_dir, args.cluster_name)
    
    print_report(k8s_namespaces, appproject_destinations)


if __name__ == '__main__':
    main()
