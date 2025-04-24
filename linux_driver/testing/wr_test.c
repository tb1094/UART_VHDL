#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>

#define BUFSIZE 512

int main(int argc, char* argv[]) {

  char fname[] = "/dev/myuart";
  char buf[BUFSIZE];
  int fd, n;

	if ((fd = open(fname, O_WRONLY)) < 0) {
		perror("open");
		return 0;
	}

	while ((n = read(STDIN_FILENO, buf, BUFSIZE-1)) > 0) {
		if (write(fd, buf, n) != n) {
      perror("write myuart\n");
			return 0;
    }
	}

  if (n < 0) {
		perror("read");
		return 0;
	}

  close(fd);

  return 0;
}
