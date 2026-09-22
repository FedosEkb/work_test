#include "main.h"

int main(int argc, char **argv) {
  
  if(int parse_res = parse_input(argc, argv)){
    if(parse_res == -1){
      return 0; // пользователь запросил справку и получил ее
    }
    return 1; // ошибка парсинга параметров
  }

  long double accum = 1.0;  
  long double temp;  

  constexpr long double max_val = std::numeric_limits<long double>::max();
  constexpr long double min_val = std::numeric_limits<long double>::min(); 
  while ( std::cin >> temp)  {
    if (temp == 0.0) {
      accum = 0.0;
      continue; // тут можно и выпрыгнуть, но надо проверит что все данные в потоке были корректны
    }

    long double abs_accum = std::abs(accum);
    long double abs_temp = std::abs(temp);
    if (abs_accum > 1.0 && abs_temp > max_val / abs_accum) { // Проверка на переполнение 
      std::cerr << "Ошибка: Переполнение (Overflow)!" << std::endl;
      return 3;
    }
    if (accum != 0.0 && abs_accum < 1.0 && abs_temp < min_val / abs_accum) { // Проверка на исчезновение порядка 
      std::cerr << "Ошибка: Исчезновение порядка (Underflow)!" << std::endl;
      return 4;
    }
    accum *= temp;
  }
   
  if (std::cin.eof() ) {
    std::cout << '\n' << accum << " success" << '\n';
    return 0;
  }

  std::cin.clear();
  std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
  std::cerr << "Не корректные символы во входном потоке" << std::endl;
  return 2;
}

int parse_input(int argc, char **argv) {
  
  CLI::App app{
      "Программам читает вещественные числа из нулевого потока подсчитывает их "
      "произведение. Разделитель пробельные символы.\n EOF - конец ввода.\n Если "
      "на вход поступят символы которые нельзя распознать как вещественен символы "
      "программа вернет - 2.\n Перполнение long double - 3 \n Исчезновение порядка -4"};

  // Парсинг аргументов
  try {
    app.parse(argc, argv);
  } catch (const CLI::ParseError &e) {
    int exit_code = app.exit(e);
    if (exit_code == 0) {
      return -1; // Был вызван --help, завершаем работу корректно
    }
    return exit_code;
  }

  if(argc != 1){
    std::cerr << "Программа не предусатривает ввод параметров";
    return 1;
  }
  return 0;
}


