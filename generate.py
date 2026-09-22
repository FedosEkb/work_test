import os
import random
import sys


def generate_floats_file():
    if len(sys.argv) < 3:
        print("Использование: python script.py <кол_во_чисел> <имя_файла>")
        sys.exit(1)

    try:
        # Теперь это строго количество чисел (строк), а не символов
        target_count = int(sys.argv[1])
    except ValueError:
        print("Ошибка: Первый параметр должен быть целым числом.")
        sys.exit(1)

    filename = sys.argv[2]

    script_dir = os.path.dirname(os.path.abspath(__file__))
    file_path = os.path.join(script_dir, filename)

    generated_lines = []

    # Цикл выполняется ровно столько раз, сколько чисел вам нужно
    for _ in range(target_count):
        num = random.uniform(0.0, 100.0)
        # Добавляем число в список как строку
        generated_lines.append(f"{num:.4f}")

    # Объединяем числа через символ переноса строки
    with open(file_path, "w", encoding="utf-8") as f:
        f.write("\n".join(generated_lines))

    print(f"Успешно создано строк (чисел): {len(generated_lines)}")
    print(f"Путь к файлу: {file_path}")


if __name__ == "__main__":
    generate_floats_file()
