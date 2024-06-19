# Lock Based Concurrency Control
## Types of Locks in DBMS
In DBMS Lock based Protocols, there are two modes for locking and unlocking data items Shared Lock (lock-S) and Exclusive Lock (lock-X).
### Shared Locks
- Shared Locks, which are often denoted as lock-S(), is defined as locks that provide Read-Only access to the information associated with them. Whenever a shared lock is used on a database, it can be read by several users, but these users who are reading the information or the data items will not have permission to edit it or make any changes to the data items.  
- To put it another way, we can say that shared locks don't provide access to write. Because numerous users can read the data items simultaneously, multiple shared locks can be installed on them at the same time, but the data item must not have any other locks connected with it.
- A shared lock, also known as a read lock, is solely used to read data objects. Read integrity is supported via shared locks.
- Shared locks can also be used to prevent records from being updated.
- S-lock is requested via the Lock-S instruction.
### Exclusive Lock
- Exclusive Lock allows the data item to be read as well as written. This is a one-time use mode that can't be utilized on the exact data item twice. To obtain X-lock, the user needs to make use of the lock-x instruction. After finishing the 'write' step, transactions can unlock the data item.
- By imposing an X lock on a transaction that needs to update a person's account balance, for example, you can allow it to proceed. As a result of the exclusive lock, the second transaction is unable to read or write.
- The other name for an exclusive lock is write lock.
- At any given time, the exclusive locks can only be owned by one transaction.
# Optimistic Concurrency Control
Optimistic concurrency control assumes that transaction conflicts occur rarely and, instead of using locks and blocking transaction execution, we can validate transactions to prevent read/write conflicts with concurrently executing transactions and ensure serializability before committing their results. Generally, transaction execution is split into three phases  
### Read phase
The transaction executes its steps in its own private context, without making any of the changes visible to other transactions. After this step, all transaction dependencies (read set) are known, as well as the side effects the transaction produces (write set).
### Validation phase
Read and write sets of concurrent transactions are checked for the presence of possible conflicts between their operations that might violate serializability. If some of the data the transaction was reading is now out-of date, or it would overwrite some of the values written by transactions that committed during its read phase, its private context is cleared and the read phase is restarted. In other words, the validation phase determines whether or not committing the transaction preserves ACID properties.
### Write phase
If the validation phase hasn’t determined any conflicts, the transaction can commit its write set from the private context to the database state else can abort the transaction.