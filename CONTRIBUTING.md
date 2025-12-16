# Contributing to Claude Code Monitoring Stack

Thank you for your interest in contributing!

## Reporting Issues

If you encounter problems:
1. Check existing issues first
2. Provide your environment details (OS, Docker version, Claude Code version)
3. Include relevant logs from `docker-compose logs`

## Pull Requests

Contributions are welcome! Please:
1. Test on multiple platforms if possible (Windows, macOS, Linux)
2. Update documentation for any feature changes
3. Ensure the dashboard JSON remains in traditional Grafana format (not Kubernetes API format)

## Testing

Before submitting:
1. Run `docker-compose up -d` on a clean environment
2. Verify the dashboard loads at http://localhost:3000
3. Check that metrics appear after configuring Claude Code telemetry

## Dashboard Customization

When modifying the dashboard:
- Export from Grafana UI (Share → Export → Save to file)
- Use the traditional format (starts with `{"title": ...}`, not `{"apiVersion": ...}`)
- Test provisioning by restarting Grafana: `docker-compose restart grafana`
