# Reading
- It’s easy to read data because clients can connect to any node in the cluster to perform reads, without having to know whether a particular node acts as a replica for that data. If a client connects to a node that doesn’t have the data it’s trying to read, the node it’s connected to will act as a coordinator node to read the data
from a node that does have it, identified by token ranges
- The read path begins when a client initiates a read query to the coordinator node
- a remote coordinator is selected per data center for any read queries that involve multiple data centers.
- If the coordinator is not itself a replica, the coordinator then sends aread request to the fastest replica, as determined by the dynamic snitch.
- The coordinator node also sends a digest request to the other replicas
- A digest request is similar to a standard read request, except the replicas return a digest, or hash, of the requested data.
- The coordinator calculates the digest hash for data returned from the fastest replica and compares it to the digests returned from the other replicas.
- If the digests are consistent, and the desired consistency level has been met, then the data from the fastest replica can be returned
- If the digests are not consistent, then the coordinator must perform a read repair
- When the replica node receives the read request, it first checks the row cache. If the row cache contains the data, it can be returned immediately
- If the data is not in the row cache, the replica node searches for the data in memtables and SSTables. There is only a single memtable for a given table, so that part of the search is straightforward
- there are potentially many physical SSTables for a single Cassandra table, each of which may contain a portion of the requested data.
- The first step in searching SSTables on disk is to use a Bloom filter to determine whether the requested partition does not exist in a given SSTable, which would make it unnecessary to search that SSTable
# Write Path
- The write path begins when a client initiates a write query to a Cassandra node that serves as the coordinator for this request
- The coordinator node uses the partitioner to identify which nodes in the cluster are replicas, according to the replication factor for the keyspace
- The coordinator node may itself be a replica, especially if the client is using a token-aware load balancing policy. If the coordinator knows that there are not enough replicas up to satisfy the requested consistency level, it returns an error immediately.
- Next, the coordinator node sends simultaneous write requests to all local replicas for the data being written.
- If the cluster spans multiple data centers, the local coordinator node selects a remote coordinator in each of the other data centers to forward the write to the replicas in that data center
- Each of the remote replicas acknowledges the write directly to the original coordinator node
- The coordinator waits for the replicas to respond. Once a sufficient number of replicas have responded to satisfy the consistency level, the coordinator acknowledges the write to the client.
- If a replica doesn’t respond within the timeout, it is presumed to be down, and a hint is stored for the write. A hint does not count as a successful replica write unless the consistency level ANY is used.
- First, the replica node receives the write request and immediately writes the data to the commit log
- Next, the replica node writes the data to a memtable
- If row caching is used and the row is in the cache, the row is invalidated
- If the write causes either the commit log or memtable to pass its maximum thresholds, a flush is scheduled to run
- At this point, the write is considered to have succeeded and the node can reply to the coordinator node or client
- After returning, the node executes a flush if one was scheduled. The contents of each memtable are stored as SSTables on disk, and the commit log is cleared
- After the flush completes, additional tasks are scheduled to check if compaction is needed, and then a compaction is performed if necessary

# Delete Path :
In Cassandra, a delete does not actually remove the data immediately. There’s a simple reason for this: Cassandra’s durable, eventually consistent, distributed design.If Cassandra had a traditional design for deletes, any nodes that were down at the time of a delete would not receive the delete. Once one of these nodes came back online, it would mistakenly think that all of the nodes that had received the delete had actually missed a write (the data that it still has because it missed the delete), and it would start repairing all of the other nodes. So Cassandra needs a more sophisticated mechanism to support deletes. That mechanism is called a tombstone  
- A tombstone is a special marker issued in a delete, acting as a placeholder. If any replica did not receive the delete operation, the tombstone can later be propagated to those replicas when they are available again
- Each node keeps track of the age of all its tombstones. Once they reach the age configured in gc_grace_seconds (which is 10 days by default), then a compaction is run, the tombstones are garbage collected, and the corresponding disk space is recovered
- Because SSTables are immutable, the data is not deleted from the SSTable. On compaction, tombstones are accounted for, merged data is sorted, a new index is created over the sorted data, and the freshly merged, sorted, and indexed data is written to a single new file
- The assumption is that 10 days is plenty of time for you to bring a failed node back online before compaction runs. If you feel comfortable doing so, you can reduce that grace period to reclaim disk space more quickly
- Because a delete is a form of write, the consistency levels available for deletes are the same as those listed for writes.
