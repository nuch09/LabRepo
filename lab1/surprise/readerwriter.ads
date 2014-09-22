
package readerwriter is
        protected type wrapper(init : Integer) is
                procedure write(nval : in Integer);
                function read return Integer;
                private
                        value : Integer := init;
        end wrapper;
        protected type semaphore(maximum : Integer; init : integer) is
                entry signal;
                entry wait;
                function free return Boolean;
                private
                        value : Integer := init;
        end semaphore;
        protected type mon is
                entry StartRead;
                entry EndRead ;
                entry StartWrite;
                entry EndWrite;
                private
                        wantWrite : semaphore(1, 1);
                        writing: Boolean := False;
                        readers : integer := 0;
        end mon;

end readerwriter;
