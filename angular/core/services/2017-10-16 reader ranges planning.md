reader ranges

TODO
try implementing nested activity in missed yesterday.

send ranges over rather than read time in mark_summary_as_read
  this means building ranges from ids and adding mark_summary_as_read request

so we need client and server implementations of SequenceRange

marking as read should take additional ranges, merge and return an updated reader.
the string format is cool.


think about how to migrate everyone over.. add a new range. 1,last_read_sequece_id
