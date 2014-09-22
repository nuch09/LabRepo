
package body readerwriter is
        protected body wrapper is 
                procedure write(nval : in Integer) is
                begin
                        value := nval;
                end write;

                function read return Integer is
                begin
                        return value;
                end read;
        end wrapper;

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
                        when not writing and StartWrite'Count = 0 is
                begin
                        readers := readers + 1;
                end StartRead;

                ---

                entry EndRead when true is
                begin
                        readers := readers - 1;
                end EndRead;

                ---

                entry StartWrite 
                        when not writing and readers = 0 is
                begin
                        writing := true;
                end StartWrite;

                ---

                entry EndWrite when true is
                begin
                        writing := false;
                end EndWrite;
        end mon;
end readerwriter;
