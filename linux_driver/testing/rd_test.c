#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>

#define BUFSIZE 512

int main(int argc, char* argv[]) {

  char fname[] = "/dev/myuart";
  char buf[BUFSIZE];
  int fd, n;

	if ((fd = open(fname, O_RDONLY)) < 0) {
		perror("open");
		return 0;
	}

	while (1) {
    if ((n = read(fd, buf, BUFSIZE-1)) > 0) {
      buf[n] = '\0';
      printf("%s", buf);
      fflush(stdout);
    }
  }

  if (n < 0) {
		perror("read");
		return 0;
	}

  close(fd);

  return 0;
}
