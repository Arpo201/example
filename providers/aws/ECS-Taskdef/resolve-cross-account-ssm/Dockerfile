# location: example/library/bash/aws/resolve_ssm.sh
FROM amazon/aws-cli:latest

COPY resolve_ssm.sh /shared/resolve_ssm.sh
RUN chmod +x /shared/resolve_ssm.sh

WORKDIR /shared

RUN env | grep PREENV_ | sed 's/^PREENV_//' > /shared/pre-ssm-env.txt

ENTRYPOINT ["/shared/resolve_ssm.sh", "/shared/pre-ssm-env.txt", "/shared/resolved-ssm.env"]
