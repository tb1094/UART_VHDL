#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ncurses.h>
#include <unistd.h>
#include <wait.h>
#include <fcntl.h>

#define ARRAY_SIZE(a) (sizeof(a) / sizeof(a[0]))

void nc_setup();

const char *choices[] = {
  "Minesweeper",
  "nPush",
  "Battleships",
  "Greed",
  "Pong",
  "Ambassador of Pain",
  "Galaxis",
  "Mogria's Snake"
};

int main() {
  nc_setup();

  int highlight = 0;
  int choice = -1;
  int c;
  int n_choices = ARRAY_SIZE(choices);
  int height = 5;
  int width = 40;
  int starty = (LINES - height) / 2;
  int startx = (COLS - width) / 2;
  pid_t pid;

  while (1) {
    mvprintw(0, 0, "Press <q> to exit");
    attron(A_BOLD);
    mvprintw(starty - 3, startx + ((width - strlen("GAME SELECTION")) / 2), "GAME SELECTION");
    attroff(A_BOLD);

    for (int i = 0; i < n_choices; ++i) {
      if (i == highlight) {
        attron(A_REVERSE);
      }
      mvprintw(starty + i, startx + ((width - strlen(choices[i])) / 2), "%s", choices[i]);
      attroff(A_REVERSE);
    }

    c = getch();

    if (c == 'q') {
      break;
    }

    switch (c) {
      case KEY_UP:
        if (highlight > 0) {
          highlight--;
        }
        break;
      case KEY_DOWN:
        if (highlight < n_choices - 1) {
          highlight++;
        }
        break;
      case 10: // Enter key
        choice = highlight;
        break;
    }

    switch (choice) {
      case 0:
        endwin();
        pid = fork();
        if (pid == 0) { // child process
          execl("./ncurses-minesweeper/bin/minesweeper", "./ncurses-minesweeper/bin/minesweeper", NULL);
          perror("execl failed for minesweeper");
          _exit(EXIT_FAILURE);
        } else if (pid > 0) { // parent process
          int status;
          waitpid(pid, &status, 0);
          nc_setup();
          clear();
          refresh();
        }
        break;
      case 1:
        endwin();
        pid = fork();
        if (pid == 0) { // child process
          if (chdir("./npush-0.7/") != 0) {
            perror("chdir failed for npush");
            return 1;
          }
          execl("./npush", "./npush", NULL);
          perror("execl failed for npush");
          _exit(EXIT_FAILURE);
        } else if (pid > 0) { // parent process
          int status;
          waitpid(pid, &status, 0);
          nc_setup();
          clear();
          refresh();
        }
        break;
      case 2:
        endwin();
        pid = fork();
        if (pid == 0) { // child process
          execl("./bs-master/bs", "./bs-master/bs", NULL);
          perror("execl failed for bs");
          _exit(EXIT_FAILURE);
        } else if (pid > 0) { // parent process
          int status;
          waitpid(pid, &status, 0);
          nc_setup();
          clear();
          refresh();
        }
        break;
      case 3:
        endwin();
        pid = fork();
        if (pid == 0) { // child process
          execl("./greed-4.3/greed", "./greed-4.3/greed", NULL);
          perror("execl failed for greed");
          _exit(EXIT_FAILURE);
        } else if (pid > 0) { // parent process
          int status;
          waitpid(pid, &status, 0);
          nc_setup();
          clear();
          refresh();
        }
        break;
      case 4:
        endwin();
        pid = fork();
        if (pid == 0) { // child process
          execl("./pong-0.1.0/pong", "./pong-0.1.0/pong", NULL);
          perror("execl failed for pong");
          _exit(EXIT_FAILURE);
        } else if (pid > 0) { // parent process
          int status;
          waitpid(pid, &status, 0);
          nc_setup();
          clear();
          refresh();
        }
        break;
      case 5:
        endwin();
        pid = fork();
        if (pid == 0) { // child process
          if (chdir("./aop-0.6/") != 0) {
            perror("chdir failed for aop");
            return 1;
          }
          execl("./aop", "./aop", "aop-level-03.txt", NULL);
          perror("execl failed for aop");
          _exit(EXIT_FAILURE);
        } else if (pid > 0) { // parent process
          int status;
          waitpid(pid, &status, 0);
          nc_setup();
          clear();
          refresh();
        }
        break;
      case 6:
        endwin();
        pid = fork();
        if (pid == 0) { // child process
          execl("./galaxis-1.11/galaxis", "./galaxis-1.11/galaxis", NULL);
          perror("execl failed for galaxis");
          _exit(EXIT_FAILURE);
        } else if (pid > 0) { // parent process
          int status;
          waitpid(pid, &status, 0);
          nc_setup();
          clear();
          refresh();
        }
        break;
      case 7:
        endwin();
        pid = fork();
        if (pid == 0) { // child process
          execl("./msnake/src/snake", "./msnake/src/snake", NULL);
          perror("execl failed for msnake");
          _exit(EXIT_FAILURE);
        } else if (pid > 0) { // parent process
          int status;
          waitpid(pid, &status, 0);
          nc_setup();
          clear();
          refresh();
        }
        break;
    }
    choice = -1;
  }

  endwin(); // end ncurses mode
  return 0;
}

void nc_setup() {
  initscr();
  noecho();
  cbreak();
  keypad(stdscr, TRUE);
  mvprintw(2, 0, "TERM is: %s", getenv("TERM"));
  int ret = curs_set(0);
  if (ret == ERR) {
    mvprintw(1, 0, "Warning: curs_set(0) failed.");
  }
}
