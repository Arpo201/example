# Kubernetes Namespace vs ArgoCD AppProject Validator

Validates Kubernetes namespaces against ArgoCD AppProject destination configurations to identify coverage gaps and unused patterns.

## Features

- Fetches live namespaces from Kubernetes cluster
- Parses ArgoCD AppProject YAML files
- Compares actual namespaces with configured destinations
- Identifies uncovered namespaces
- Detects unused AppProject patterns
- Colorful terminal output

## Requirements

- Python 3.6+
- kubectl configured with cluster access
- PyYAML

## Installation

```bash
# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

## Usage

```bash
python main.py \
  --kubeconfig ~/.kube/config \
  --context my-context \
  --cluster-name sandbox-th \
  --appproject-dir /path/to/appprojects
```

### Arguments

- `--kubeconfig`: Path to kubeconfig file (optional, uses default if not specified)
- `--context`: Kubernetes context to use (optional)
- `--cluster-name`: Cluster name to match in AppProject destinations (required)
- `--appproject-dir`: Directory containing AppProject YAML files (required)

## Example

```bash
python main.py \
  --kubeconfig ~/.kube/sandbox-th \
  --cluster-name sandbox-th \
  --appproject-dir /path/to/appprojects
```

## Output

The script generates a detailed report showing:
- All K8s namespaces in the cluster
- AppProject destinations by project
- Namespaces covered by AppProjects
- Namespaces NOT covered by AppProjects
- AppProject patterns without matches
- Summary statistics
