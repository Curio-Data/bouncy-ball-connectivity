# Cost Breakdown

This document explains the costs associated with the Azure Container Apps deployment.

## Resources Created

| Resource | Configuration | Cost |
|----------|--------------|------|
| Container App | 0.25 vCPU, 0.5 GiB | See below |

## Pricing

Azure Container Apps uses a consumption-based pricing model:

### Free Tier (Monthly)
- 180,000 vCPU-seconds
- 360,000 GiB-seconds  
- 2,000,000 HTTP requests

### Pay-as-you-go
- ~$0.000012/vCPU-second
- ~$0.0000013/GiB-second
- ~$0.20/million HTTP requests

## Cost Estimates

With the current configuration (0.25 vCPU, 0.5 GiB, scale-to-zero):

| Scenario | Estimated Cost |
|----------|---------------|
| Idle (scale-to-zero) | $0 |
| Light usage (< 100K req/month) | $0-5/month |
| Moderate usage (< 1M req/month) | $5-20/month |

## Scale-to-Zero

The app is configured with `--min-replicas 0`, which means:
- No cost when no requests are incoming
- App starts up on first request (cold start ~10-15 seconds)
- Scales to max 1 replica under load

## Monitoring Costs

```bash
# Check current costs
az cost analysis query \
  --scope "/subscriptions/<sub-id>/resourceGroups/kbrs-feasibility" \
  --timeframe MonthToDate
```

## Comparison to VMs

Container Apps is significantly cheaper than VMs for this workload:
- VM (B1s): ~$7/month minimum
- Container Apps (idle): ~$0/month
