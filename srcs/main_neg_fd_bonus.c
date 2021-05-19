#include "../get_next_line_bonus.h"
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

int	main(int ac, char **av)
{
	(void)av;
	int	fd;
	char	*line;

	alarm(3);
	if (ac == 1)
	{
		fd = -1;
		while (get_next_line(fd, &line) == 1)
		{
			printf("%s\n", line);
			free(line);
		}
		free(line);
	}
	return (0);
}

