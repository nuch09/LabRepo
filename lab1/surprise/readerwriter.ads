
package readerwriter is
        protected type RWLock is
                entry StartRead;
                procedure EndRead;
                entry StartWrite;
                procedure EndWrite;
                private
                        writing: Boolean := False;
                        readers : integer := 0;
        end RWLock;
end readerwriter;
