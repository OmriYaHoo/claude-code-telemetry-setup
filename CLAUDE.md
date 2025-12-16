# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This repository provides a Docker-based monitoring stack for Claude Code telemetry using OpenTelemetry, Prometheus, and Grafana. It enables tracking of usage metrics, costs, token consumption, and activity patterns.

**Dashboard includes 22 data panels organized in 4 sections:**

**Token Stats**: Input/output tokens, cache metrics, efficiency gauge
**Breakdowns**: Pie charts for tokens by type, tokens by model, cost by model
**Time Tracking**: Activity distribution, productivity ratio gauge
**Time Series**: Token usage trends, cost over time, model usage patterns

Panel types: 12 stat panels, 4 time series graphs, 3 pie charts, 2 gauges, 1 bar gauge

## Architecture

The monitoring stack consists of three services:

1. **OpenTelemetry Collector** (port 4317/4318): Receives telemetry data from Claude Code via OTLP protocol
2. **Prometheus** (port 9090): Scrapes metrics from the OTel Collector and stores time-series data
3. **Grafana** (port 3000): Visualization layer with pre-provisioned dashboards

Data flows: Claude Code → OTel Collector (OTLP) → Prometheus (scrape) → Grafana (query)

## Common Commands

### Start the monitoring stack
```bash
docker-compose up -d
```

### Stop the monitoring stack
```bash
docker-compose down
```

### Stop and remove all data (including metrics)
```bash
docker-compose down -v
```

### View logs
```bash
# All services
docker-compose logs

# Specific service
docker-compose logs grafana
docker-compose logs prometheus
docker-compose logs otel-collector
```

### Check container status
```bash
docker-compose ps
```

### Restart a specific service
```bash
docker-compose restart grafana
docker-compose restart prometheus
docker-compose restart otel-collector
```

## Key Configuration Files

- `docker-compose.yml`: Defines the three-service stack with networking and volumes
- `otel-collector-config.yaml`: OTel Collector receivers (OTLP), processors (batch), and exporters (Prometheus + logging)
- `prometheus.yml`: Prometheus scrape config targeting `otel-collector:8889` every 15 seconds
- `grafana-provisioning/datasources/prometheus.yml`: Auto-provisions Prometheus as Grafana datasource
- `grafana-provisioning/dashboards/`: Dashboard provisioning configuration and the Claude Code dashboard JSON

## Claude Code Integration

Users must add these environment variables to their Claude Code settings file:
- **macOS/Linux**: `~/.claude/settings.json`
- **Windows**: `%USERPROFILE%\.claude\settings.json`

```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp",
    "OTEL_LOGS_EXPORTER": "otlp",
    "OTEL_EXPORTER_OTLP_PROTOCOL": "grpc",
    "OTEL_EXPORTER_OTLP_ENDPOINT": "http://localhost:4317"
  }
}
```

Optional: Add `OTEL_RESOURCE_ATTRIBUTES` for multi-team tracking (e.g., `"team.id=platform,department=engineering"`).

## Customizing Dashboards

1. Make changes in Grafana UI (http://localhost:3000, default login: admin/admin)
2. Export the dashboard (Share → Export → Save to file)
3. Replace `grafana-provisioning/dashboards/claude-code-dashboard.json`
4. Restart Grafana: `docker-compose restart grafana`

**Important:** When exporting dashboards, ensure they're in the traditional Grafana JSON format (with a `"dashboard"` key at the root), not the Kubernetes-style format (with `"apiVersion"`, `"kind"`, `"metadata"` keys). File-based provisioning only works with the traditional format.

## Troubleshooting

### No data in Grafana
1. Check OTel Collector logs: `docker logs claude-code-otel-collector`
2. Verify Prometheus targets are UP: http://localhost:9090 → Status → Targets
3. Ensure Claude Code is running with telemetry enabled and has been restarted after settings changes

### Connection issues
All services must be on the same Docker network (the compose file creates a `monitoring` network automatically). Check with `docker network ls` and `docker network inspect cc-monitoring_monitoring`.

## Data Persistence

Prometheus and Grafana use named Docker volumes (`prometheus-data` and `grafana-data`) for persistence. These survive container restarts but are removed with `docker-compose down -v`.
