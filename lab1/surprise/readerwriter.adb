
package body readerwriter is
        protected body semaphore is
                entry signal
                        when value < maximum is
                begin
                        value := value + 1;
                end signal;

                entry wait
                        when value > 0 is
                begin
                        value := value - 1;
                end wait;

                function free return Boolean is
                begin
                        return value = 0;
                end free;
        end semaphore;

        protected body mon is
                entry StartRead
                        when not writing and wantWrite.free is
                begin
                        readers := readers + 1;
                end StartRead;

                ---

                entry EndRead when true is
                begin
                        readers := readers - 1;
                end EndRead;

                ---

                procedure StartWrite is
                begin
                        wantWrite.wait;
                        --writing = true;
                        DoStartWrite;
                end StartWrite;

                ---

                entry DoStartWrite
                        when not writing and readers = 0 is
                begin
                        --writing := true;
                        null;
                end DoStartWrite;

                ---

                entry EndWrite when true is
                begin
                        --writing := false;
                        wantWrite.signal;
                end EndWrite;
        end mon;
end readerwriter;
