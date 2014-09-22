
package body readerwriter is
        protected body RWLock is
                entry StartRead
                        -- check for active and waiting writers ('Count is queue length)
                        when not writing and StartWrite'Count = 0 is
                begin
                        readers := readers + 1;
                end StartRead;

                ----

                procedure EndRead is
                begin
                        readers := readers - 1;
                end EndRead;

                ----

                entry StartWrite 
                        -- needs exclusive access
                        when not writing and readers = 0 is
                begin
                        writing := true;
                end StartWrite;

                ----

                procedure EndWrite is
                begin
                        writing := false;
                end EndWrite;
        end RWLock;
end readerwriter;
