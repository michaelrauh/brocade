```mermaid
flowchart LR
    User-->|Corpus|Context
    Context-->Context_Queue
    Context-->Context_DB
    Context-->Work_Queue
    Work_Queue-->Worker
    Worker-->Context
    Worker-->DB_Queue
    DB_Queue-->Feeder
    Feeder-->Result_DB
    Result_DB-->Follower
    Follower-->Work_Queue
```
