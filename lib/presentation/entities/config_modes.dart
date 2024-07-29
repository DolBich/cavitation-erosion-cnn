enum ConfigModes {
  endless,
  iterator,
  error,
}

extension ConfigModesX on ConfigModes {
  String get title {
    switch(this) {
      case ConfigModes.error:
        return 'По значению ошибки';
      case ConfigModes.iterator:
        return 'По числу итераций';
      case ConfigModes.endless:
        return 'Без условий';
    }
  }

  String get label {
    switch(this) {
      case ConfigModes.error:
        return 'Введите неотрицательное число';
      case ConfigModes.iterator:
        return 'Введите целое положительное число';
      case ConfigModes.endless:
        return '';
    }
  }

  String get hint {
    switch(this) {
      case ConfigModes.error:
        return 'Значение ошибки для каждого из образцов, по достижению которой тренировка остановится автоматически';
      case ConfigModes.iterator:
        return 'Число итераций, по завершению которых тренировка остановится автоматически';
      case ConfigModes.endless:
        return 'Обучение остановится только при ручном нажатии на кнопку остановки';
    }
  }

  String get regExpFormat {
    switch(this) {
      case ConfigModes.error:
        return '^\$|^(0?|([1-9][0-9]{0,9}))(\\.[0-9]{0,4})?\$';
      case ConfigModes.iterator:
        return '^\$|^(0?|([1-9][0-9]{0,9}))\$';
      case ConfigModes.endless:
        return '';
    }
  }

}