#include "../get_next_line_bonus.h"
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

int	main(void)
{
	int		fd;
	int		fd2;
	int		fd3;
	int		fd4;
	char	*line;

	alarm(3);
	fd = open("files/four_lines", O_RDONLY);
	get_next_line(fd, &line);
	printf("%s\n", line);
	free(line);
	fd2 = open("files/five_big_lines", O_RDONLY);
	get_next_line(fd2, &line);
	printf("%s\n", line);
	free(line);
	fd3 = open("files/six_short_lines", O_RDONLY);
	get_next_line(fd3, &line);
	printf("%s\n", line);
	free(line);
	fd4 = open("files/lorem_big_file", O_RDONLY);
	get_next_line(fd4, &line);
	printf("%s\n", line);
	free(line);
	get_next_line(fd2, &line);
	printf("%s\n", line);
	free(line);
	get_next_line(fd, &line);
	printf("%s\n", line);
	free(line);
	get_next_line(fd4, &line);
	printf("%s\n", line);
	free(line);
	get_next_line(fd4, &line);
	printf("%s\n", line);
	free(line);
	get_next_line(fd3, &line);
	printf("%s\n", line);
	free(line);
	close(fd);
	close(fd2);
	close(fd3);
	close(fd4);
	return (0);
}
