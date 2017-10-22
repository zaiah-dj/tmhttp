# tmhttp

## Summary
<p>
tmhttp is short for 'Tubular Modular's HTTP'.  It's a small and easy to compile C module to handle HTTP packets.  It is not quite single file, but it is darn close and would need only a light amount of tuning to work this way.
</p>


## Usage

### Building
<p>
Right now, tmhttp needs two dependencies to work correctly.  It is built off of nw.c, a networking module that makes it easy to spawn web servers, and single.c, a set of utilities that make life easier for C programmers.
</p>

<p>
To build the library and its tests, use the following:
<pre>
$ make && make tests
</pre>

To add HTTP capability to a program called megadeth comprised of a source file, megadeth.c, use the following:
<pre>
$ export CFLAGS=-Wall -Werror -Wno-unused -std=c99 -DSQROOGE_H
$ gcc -o megadeth -std=c99 -Wall -Wno-error -Wno-unused -DSQROOGE megadeth.c single.c nw.c http.c
$ ls *
</pre>

Finally, to simply build an object for your own programs 
<pre>
$ export CFLAGS=-Wall -Werror -Wno-unused -std=c99 -DSQROOGE_H
$ gcc -c $(CFLAGS) single.c nw.c http.c
$ ls *.o  # Lists nw.o http.o single.o 
</pre>

</p>


## Todo 
<p>
While this library is used quite a bit and well-tested in other programs, it could be smaller and easier to embed.  A single file library (or two files at most) is the ideal goal and may happen in the near future. 
</p>
