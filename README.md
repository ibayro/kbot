- [x] Implement monitoring system on OpenTelemetry (Grafana->Loki/Prometheus)

# Open-telemetry observability

Sample configuration for Kbot that send logs to [OpenTelemetry Collector] and metrics to [OpenTelemetry Collector] or [Prometheus].

## Prerequisites

- [Docker]
- [Docker Compose]

## How to run

```bash
export TELE_TOKEN=<TOKEN>
docker-compose up
```
![image](https://github.com/ibayro/kbot/assets/104074570/3608da6a-ece7-48f5-8b2a-430bfb2e7fef)
![image](https://github.com/ibayro/kbot/assets/104074570/f7d123da-f3e8-4c0f-b0cb-ed442d3dc371)
