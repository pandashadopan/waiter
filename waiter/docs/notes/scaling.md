# Waiter's Scaling Logic

* `autoscaler-goroutine` runs in a loop every `timeout-interval-ms` ms.
* `autoscaler-goroutine` determines global services state and triggers scaling of individual services via `scale-services`.
    * `scale-services` calls `scale-service` per service with `expired-instances`, `healthy-instances`, `outstanding-requests`, `target-instances`, `instances` (scheduled instances) to retrieve the `scale-amount`.
        * `scale-service` computes `scale-amount`, `scale-to-instances` and `target-instances` as `scaling-state`.
    * `scale-services` uses `scale-amount` to determine calling `apply-scaling!` with `outstanding-requests`, `task-count` (requested instances), `instances` (scheduled instances), `scale-amount` and `scale-to-instances`.
        * `apply-scaling!` sends scaling request along `executor-multiplexer-chan`.
        * `service-scaling-executor` reads `executor-multiplexer-chan` to trigger scale-up or scale-down calls.
    * `scale-services` returns `scaling-state` to use as seed data for next iteration of scaling computation for the service.
