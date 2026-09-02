"""
Custom EDA Source Plugin - Skeleton
====================================
This is an annotated skeleton for writing your own EDA event source plugin.

How it works:
  - EDA calls the `main()` function when a rulebook activation starts.
  - `main()` receives a queue and your plugin's arguments (from the rulebook YAML).
  - Your plugin generates events and puts them onto the queue.
  - The rules engine picks up events from the queue and evaluates them.

To use this in a real collection, place this file at:
  <namespace>/<collection>/plugins/event_source/<plugin_name>.py

In a rulebook, reference it as:
  sources:
    - <namespace>.<collection>.<plugin_name>:
        interval: 10
        threshold: 80

"""

import asyncio
import logging
from typing import Any

logger = logging.getLogger(__name__)


async def main(queue: asyncio.Queue, args: dict[str, Any]) -> None:
    """
    Entry point for the source plugin.

    Parameters
    ----------
    queue : asyncio.Queue
        Put event dictionaries onto this queue. Each dict becomes an event
        that the rules engine evaluates.
    args : dict
        Arguments from the rulebook YAML source configuration.
        Example: if the rulebook has `interval: 10`, then args["interval"] == 10.
    """
    interval = int(args.get("interval", 30))
    threshold = int(args.get("threshold", 80))

    logger.info(
        "Custom source plugin started (interval=%ds, threshold=%d)",
        interval,
        threshold,
    )

    # -----------------------------------------------------------------------
    # Main event loop
    # -----------------------------------------------------------------------
    # Replace the simulated logic below with your actual event-generating code:
    #   - Poll an API
    #   - Listen on a socket
    #   - Read from a queue/bus
    #   - Watch a database table
    # -----------------------------------------------------------------------

    counter = 0
    while True:
        counter += 1

        # --- YOUR LOGIC HERE ---
        # Example: simulate a metric that occasionally exceeds the threshold
        import random

        metric_value = random.randint(0, 100)

        if metric_value > threshold:
            event = {
                "source": "custom_source",
                "metric": metric_value,
                "threshold": threshold,
                "counter": counter,
                "message": f"Metric {metric_value} exceeded threshold {threshold}",
            }

            logger.info("Emitting event: %s", event)
            await queue.put(event)

        await asyncio.sleep(interval)
