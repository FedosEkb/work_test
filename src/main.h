#ifndef TEST_PROJ_H
#define TEST_PROJ_H


#include <iostream>
#include <CLI/CLI.hpp>
#include <limits>
#include <cmath>


/**
 * @brief парсинг параметров процесса
 * 
 * @param argc из main
 * @param argv из main
 * @return int статус разбора 0 - успех,  -1 - пользователь запросил справку и он ее получил. остальные значения - фиаско
 */
int parse_input(int argc, char **argv);

#endif /* TEST_PROJ_H */