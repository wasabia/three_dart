// ignore: camel_case_types
class console {
  static error(String message, [dynamic variables]) {
    _print(message, variables);
  }

  static warn(String message, [dynamic variables]) {
    _print(message, variables);
  }

  static _print(String message, [dynamic variables]) {
    print(message + (variables == null ? "" : variables.toString()));
  }
}

final undefined = null;
