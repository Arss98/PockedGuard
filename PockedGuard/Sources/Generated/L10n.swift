// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum Alerts {
    /// Цвет добавлен в палитру
    internal static let colorAdded = L10n.tr("Localizable", "alerts.color_added", fallback: "Цвет добавлен в палитру")
    internal enum DuplicateTemplateIcon {
      /// Обнаружен существующий шаблон с данной иконкой. Вы можете заменить его или выбрать другую иконку для нового шаблона.
      internal static let message = L10n.tr("Localizable", "alerts.duplicate_template_icon.message", fallback: "Обнаружен существующий шаблон с данной иконкой. Вы можете заменить его или выбрать другую иконку для нового шаблона.")
      /// Иконка уже используется
      internal static let title = L10n.tr("Localizable", "alerts.duplicate_template_icon.title", fallback: "Иконка уже используется")
    }
    internal enum PrimaryAccount {
      /// Вы уверены, что хотите сделать счет "%@" основным? Это заменит текущий основной счет.
      internal static func message(_ p1: Any) -> String {
        return L10n.tr("Localizable", "alerts.primary_account.message", String(describing: p1), fallback: "Вы уверены, что хотите сделать счет \"%@\" основным? Это заменит текущий основной счет.")
      }
      /// Установить основной счет
      internal static let title = L10n.tr("Localizable", "alerts.primary_account.title", fallback: "Установить основной счет")
    }
    internal enum SystemCategory {
      /// Категория "%@" является системной. Вы уверены, что хотите %@ эту категорию?
      internal static func message(_ p1: Any, _ p2: Any) -> String {
        return L10n.tr("Localizable", "alerts.system_category.message", String(describing: p1), String(describing: p2), fallback: "Категория \"%@\" является системной. Вы уверены, что хотите %@ эту категорию?")
      }
      /// ===== ALERTS =====
      internal static let title = L10n.tr("Localizable", "alerts.system_category.title", fallback: "Системная категория")
    }
  }
  internal enum Analytics {
    /// Начните вести учёт, и система покажет, как ваши финансы меняются во времени: за день, неделю, месяц или год
    internal static let empty = L10n.tr("Localizable", "analytics.empty", fallback: "Начните вести учёт, и система покажет, как ваши финансы меняются во времени: за день, неделю, месяц или год")
    internal enum Expenses {
      /// Ваши расходы сократились на %@
      internal static func decreased(_ p1: Any) -> String {
        return L10n.tr("Localizable", "analytics.expenses.decreased", String(describing: p1), fallback: "Ваши расходы сократились на %@")
      }
      /// Ваши расходы увеличились на %@
      internal static func increased(_ p1: Any) -> String {
        return L10n.tr("Localizable", "analytics.expenses.increased", String(describing: p1), fallback: "Ваши расходы увеличились на %@")
      }
    }
    internal enum Income {
      /// Ваш доход сократился на %@
      internal static func decreased(_ p1: Any) -> String {
        return L10n.tr("Localizable", "analytics.income.decreased", String(describing: p1), fallback: "Ваш доход сократился на %@")
      }
      /// Ваш доход вырос на %@
      internal static func increased(_ p1: Any) -> String {
        return L10n.tr("Localizable", "analytics.income.increased", String(describing: p1), fallback: "Ваш доход вырос на %@")
      }
    }
    internal enum Loss {
      /// Ваш убыток уменьшился на %@
      internal static func decreased(_ p1: Any) -> String {
        return L10n.tr("Localizable", "analytics.loss.decreased", String(describing: p1), fallback: "Ваш убыток уменьшился на %@")
      }
      /// Ваш убыток возрос на %@
      internal static func increased(_ p1: Any) -> String {
        return L10n.tr("Localizable", "analytics.loss.increased", String(describing: p1), fallback: "Ваш убыток возрос на %@")
      }
    }
    internal enum Rating {
      /// ===== ANALYTICS =====
      internal static let excellent = L10n.tr("Localizable", "analytics.rating.excellent", fallback: "Отлично!")
      /// Так держать!
      internal static let good = L10n.tr("Localizable", "analytics.rating.good", fallback: "Так держать!")
      /// Стабильно
      internal static let neutral = L10n.tr("Localizable", "analytics.rating.neutral", fallback: "Стабильно")
      /// Внимание!
      internal static let warning = L10n.tr("Localizable", "analytics.rating.warning", fallback: "Внимание!")
    }
  }
  internal enum Categories {
    /// Название счета
    internal static let accountName = L10n.tr("Localizable", "categories.account_name", fallback: "Название счета")
    /// Введите название счета
    internal static let accountNamePlaceholder = L10n.tr("Localizable", "categories.account_name_placeholder", fallback: "Введите название счета")
    /// Добавить счет
    internal static let addAccount = L10n.tr("Localizable", "categories.add_account", fallback: "Добавить счет")
    /// ===== CATEGORIES =====
    internal static let addCategory = L10n.tr("Localizable", "categories.add_category", fallback: "Добавить категорию")
    /// Добавить шаблон
    internal static let addTemplate = L10n.tr("Localizable", "categories.add_template", fallback: "Добавить шаблон")
    /// Введите сумму (не обязательно)
    internal static let amountPlaceholder = L10n.tr("Localizable", "categories.amount_placeholder", fallback: "Введите сумму (не обязательно)")
    /// Название категории
    internal static let categoryName = L10n.tr("Localizable", "categories.category_name", fallback: "Название категории")
    /// Введите название категории
    internal static let categoryNamePlaceholder = L10n.tr("Localizable", "categories.category_name_placeholder", fallback: "Введите название категории")
    /// Цвет категории
    internal static let colorTitle = L10n.tr("Localizable", "categories.color_title", fallback: "Цвет категории")
    /// Тип валюты
    internal static let currencyType = L10n.tr("Localizable", "categories.currency_type", fallback: "Тип валюты")
    /// Редактировать счет
    internal static let editAccount = L10n.tr("Localizable", "categories.edit_account", fallback: "Редактировать счет")
    /// Редактировать категорию
    internal static let editCategory = L10n.tr("Localizable", "categories.edit_category", fallback: "Редактировать категорию")
    /// Редактировать шаблон
    internal static let editTemplate = L10n.tr("Localizable", "categories.edit_template", fallback: "Редактировать шаблон")
    /// Сделать основным
    internal static let setPrimary = L10n.tr("Localizable", "categories.set_primary", fallback: "Сделать основным")
    /// Укажите сумму, если хотите создать шаблон
    /// с фиксированной суммой транзакции.
    /// Если оставить поле пустым, сумму
    /// нужно будет вводить при каждой трате.
    internal static let templateAmountInfo = L10n.tr("Localizable", "categories.template_amount_info", fallback: "Укажите сумму, если хотите создать шаблон\nс фиксированной суммой транзакции.\nЕсли оставить поле пустым, сумму\nнужно будет вводить при каждой трате.")
  }
  internal enum Common {
    /// Сумма
    internal static let amount = L10n.tr("Localizable", "common.amount", fallback: "Сумма")
    /// Аналитика
    internal static let analytics = L10n.tr("Localizable", "common.analytics", fallback: "Аналитика")
    /// ===== COMMON =====
    internal static let appName = L10n.tr("Localizable", "common.app_name", fallback: "Pocked Guard")
    /// Отмена
    internal static let cancel = L10n.tr("Localizable", "common.cancel", fallback: "Отмена")
    /// Продолжить
    internal static let `continue` = L10n.tr("Localizable", "common.continue", fallback: "Продолжить")
    /// Удалить
    internal static let delete = L10n.tr("Localizable", "common.delete", fallback: "Удалить")
    /// Готово
    internal static let done = L10n.tr("Localizable", "common.done", fallback: "Готово")
    /// Редактировать
    internal static let edit = L10n.tr("Localizable", "common.edit", fallback: "Редактировать")
    /// Иконка
    internal static let icon = L10n.tr("Localizable", "common.icon", fallback: "Иконка")
    /// Ок
    internal static let ok = L10n.tr("Localizable", "common.ok", fallback: "Ок")
    /// Заменить
    internal static let replace = L10n.tr("Localizable", "common.replace", fallback: "Заменить")
    /// Еще
    internal static let still = L10n.tr("Localizable", "common.still", fallback: "Еще")
    /// Сегодня
    internal static let today = L10n.tr("Localizable", "common.today", fallback: "Сегодня")
    /// Итого
    internal static let total = L10n.tr("Localizable", "common.total", fallback: "Итого")
    /// Свернуть
    internal static let wrap = L10n.tr("Localizable", "common.wrap", fallback: "Свернуть")
  }
  internal enum Error {
    /// Счет с таким названием уже существует
    internal static let accountNameDuplicate = L10n.tr("Localizable", "error.account_name_duplicate", fallback: "Счет с таким названием уже существует")
    /// Необходимо ввести название счета
    internal static let accountNameInvalid = L10n.tr("Localizable", "error.account_name_invalid", fallback: "Необходимо ввести название счета")
    /// Счета не найдены. Сначала создайте счет
    internal static let accountsEmpty = L10n.tr("Localizable", "error.accounts_empty", fallback: "Счета не найдены. Сначала создайте счет")
    /// Сумма должна быть больше нуля
    internal static let amountInvalid = L10n.tr("Localizable", "error.amount_invalid", fallback: "Сумма должна быть больше нуля")
    /// Список категорий пуст
    internal static let categoriesEmpty = L10n.tr("Localizable", "error.categories_empty", fallback: "Список категорий пуст")
    /// Необходимо выбрать цвет категории
    internal static let categoryColorEmpty = L10n.tr("Localizable", "error.category_color_empty", fallback: "Необходимо выбрать цвет категории")
    /// Категория с таким названием уже существует
    internal static let categoryNameDuplicate = L10n.tr("Localizable", "error.category_name_duplicate", fallback: "Категория с таким названием уже существует")
    /// Необходимо ввести название категории
    internal static let categoryNameInvalid = L10n.tr("Localizable", "error.category_name_invalid", fallback: "Необходимо ввести название категории")
    /// Пожалуйста, выберите категорию
    internal static let categoryNotSelected = L10n.tr("Localizable", "error.category_not_selected", fallback: "Пожалуйста, выберите категорию")
    /// Поле описания не может быть пустым
    internal static let descriptionEmpty = L10n.tr("Localizable", "error.description_empty", fallback: "Поле описания не может быть пустым")
    /// Поле не может быть пустым
    internal static let fieldEmpty = L10n.tr("Localizable", "error.field_empty", fallback: "Поле не может быть пустым")
    /// Недостаточно средств на счете
    internal static let insufficientFunds = L10n.tr("Localizable", "error.insufficient_funds", fallback: "Недостаточно средств на счете")
    /// Необходимо выбрать категорию или ввести сумму
    internal static let templateCategoryOrAmountEmpty = L10n.tr("Localizable", "error.template_category_or_amount_empty", fallback: "Необходимо выбрать категорию или ввести сумму")
    /// Необходимо выбрать иконку шаблона
    internal static let templateIconEmpty = L10n.tr("Localizable", "error.template_icon_empty", fallback: "Необходимо выбрать иконку шаблона")
    /// Список шаблонов пуст
    internal static let templatesEmpty = L10n.tr("Localizable", "error.templates_empty", fallback: "Список шаблонов пуст")
    /// ===== ERRORS =====
    internal static let title = L10n.tr("Localizable", "error.title", fallback: "Ошибка")
    /// Поле заголовка не может быть пустым
    internal static let titleEmpty = L10n.tr("Localizable", "error.title_empty", fallback: "Поле заголовка не может быть пустым")
    /// Произошла неизвестная ошибка
    internal static let unknown = L10n.tr("Localizable", "error.unknown", fallback: "Произошла неизвестная ошибка")
    internal enum Data {
      /// Ошибка при загрузке счетов
      internal static let accountsFetchFailed = L10n.tr("Localizable", "error.data.accounts_fetch_failed", fallback: "Ошибка при загрузке счетов")
      /// Ошибка при создании данных по умолчанию
      internal static let createDefaultFailed = L10n.tr("Localizable", "error.data.create_default_failed", fallback: "Ошибка при создании данных по умолчанию")
      /// Ошибка при загрузке данных
      internal static let fetchFailed = L10n.tr("Localizable", "error.data.fetch_failed", fallback: "Ошибка при загрузке данных")
      /// Ошибка при загрузке операций
      internal static let transactionsFetchFailed = L10n.tr("Localizable", "error.data.transactions_fetch_failed", fallback: "Ошибка при загрузке операций")
    }
    internal enum Notifications {
      /// Не удалось удалить уведомление
      internal static let deleteFailed = L10n.tr("Localizable", "error.notifications.delete_failed", fallback: "Не удалось удалить уведомление")
      /// Не удалось загрузить уведомления
      internal static let fetchFailed = L10n.tr("Localizable", "error.notifications.fetch_failed", fallback: "Не удалось загрузить уведомления")
      /// Не удалось запланировать уведомление
      internal static let schedulingFailed = L10n.tr("Localizable", "error.notifications.scheduling_failed", fallback: "Не удалось запланировать уведомление")
      /// Не удалось обновить уведомление
      internal static let updateFailed = L10n.tr("Localizable", "error.notifications.update_failed", fallback: "Не удалось обновить уведомление")
    }
  }
  internal enum Finance {
    /// Основной счет
    internal static let defaultAccount = L10n.tr("Localizable", "finance.default_account", fallback: "Основной счет")
    /// Расходы
    internal static let expenses = L10n.tr("Localizable", "finance.expenses", fallback: "Расходы")
    /// ===== FINANCE =====
    internal static let income = L10n.tr("Localizable", "finance.income", fallback: "Доходы")
    /// Убыток
    internal static let loss = L10n.tr("Localizable", "finance.loss", fallback: "Убыток")
    internal enum Categories {
      /// Счета
      internal static let accounts = L10n.tr("Localizable", "finance.categories.accounts", fallback: "Счета")
      /// Категории
      internal static let categories = L10n.tr("Localizable", "finance.categories.categories", fallback: "Категории")
      /// Шаблоны
      internal static let templates = L10n.tr("Localizable", "finance.categories.templates", fallback: "Шаблоны")
      /// Категории и шаблоны
      internal static let title = L10n.tr("Localizable", "finance.categories.title", fallback: "Категории и шаблоны")
    }
    internal enum Currency {
      /// EUR
      internal static let eur = L10n.tr("Localizable", "finance.currency.eur", fallback: "EUR")
      /// RUB
      internal static let rub = L10n.tr("Localizable", "finance.currency.rub", fallback: "RUB")
      /// USD
      internal static let usd = L10n.tr("Localizable", "finance.currency.usd", fallback: "USD")
    }
    internal enum Transactions {
      /// Операции за выбранный период не найдены
      internal static let empty = L10n.tr("Localizable", "finance.transactions.empty", fallback: "Операции за выбранный период не найдены")
    }
  }
  internal enum IncomeCategories {
    /// Подарки
    internal static let gifts = L10n.tr("Localizable", "income_categories.gifts", fallback: "Подарки")
    /// Инвестиции
    internal static let investments = L10n.tr("Localizable", "income_categories.investments", fallback: "Инвестиции")
    /// Другое
    internal static let other = L10n.tr("Localizable", "income_categories.other", fallback: "Другое")
    /// ===== INCOME CATEGORIES =====
    internal static let salary = L10n.tr("Localizable", "income_categories.salary", fallback: "Зарплата")
  }
  internal enum Month {
    /// Апрель
    internal static let april = L10n.tr("Localizable", "month.april", fallback: "Апрель")
    /// Август
    internal static let august = L10n.tr("Localizable", "month.august", fallback: "Август")
    /// Декабрь
    internal static let december = L10n.tr("Localizable", "month.december", fallback: "Декабрь")
    /// Февраль
    internal static let february = L10n.tr("Localizable", "month.february", fallback: "Февраль")
    /// ===== MONTHS =====
    internal static let january = L10n.tr("Localizable", "month.january", fallback: "Январь")
    /// Июль
    internal static let july = L10n.tr("Localizable", "month.july", fallback: "Июль")
    /// Июнь
    internal static let june = L10n.tr("Localizable", "month.june", fallback: "Июнь")
    /// Март
    internal static let march = L10n.tr("Localizable", "month.march", fallback: "Март")
    /// Май
    internal static let may = L10n.tr("Localizable", "month.may", fallback: "Май")
    /// Ноябрь
    internal static let november = L10n.tr("Localizable", "month.november", fallback: "Ноябрь")
    /// Октябрь
    internal static let october = L10n.tr("Localizable", "month.october", fallback: "Октябрь")
    /// Сентябрь
    internal static let september = L10n.tr("Localizable", "month.september", fallback: "Сентябрь")
  }
  internal enum Notifications {
    /// Создать напоминание
    internal static let createTitle = L10n.tr("Localizable", "notifications.create_title", fallback: "Создать напоминание")
    /// Редактировать
    internal static let editTitle = L10n.tr("Localizable", "notifications.edit_title", fallback: "Редактировать")
    /// Ваш список напоминаний пуст. Добавьте новые напоминания, чтобы ничего не забыть!
    internal static let empty = L10n.tr("Localizable", "notifications.empty", fallback: "Ваш список напоминаний пуст. Добавьте новые напоминания, чтобы ничего не забыть!")
    /// Каждый день
    internal static let everyDay = L10n.tr("Localizable", "notifications.every_day", fallback: "Каждый день")
    /// Каждый месяц
    internal static let everyMonth = L10n.tr("Localizable", "notifications.every_month", fallback: "Каждый месяц")
    /// Каждую неделю
    internal static let everyWeek = L10n.tr("Localizable", "notifications.every_week", fallback: "Каждую неделю")
    /// Периодичность
    internal static let frequency = L10n.tr("Localizable", "notifications.frequency", fallback: "Периодичность")
    /// Один раз
    internal static let once = L10n.tr("Localizable", "notifications.once", fallback: "Один раз")
    /// Заголовок
    internal static let reminderTitle = L10n.tr("Localizable", "notifications.reminder_title", fallback: "Заголовок")
    /// Дата начала
    internal static let startDate = L10n.tr("Localizable", "notifications.start_date", fallback: "Дата начала")
    /// Текст
    internal static let text = L10n.tr("Localizable", "notifications.text", fallback: "Текст")
    /// Текст напоминания
    internal static let textPlaceholder = L10n.tr("Localizable", "notifications.text_placeholder", fallback: "Текст напоминания")
    /// Время
    internal static let time = L10n.tr("Localizable", "notifications.time", fallback: "Время")
    /// ===== NOTIFICATIONS =====
    internal static let title = L10n.tr("Localizable", "notifications.title", fallback: "Напоминания")
    /// Заголовок напоминания
    internal static let titlePlaceholder = L10n.tr("Localizable", "notifications.title_placeholder", fallback: "Заголовок напоминания")
  }
  internal enum Onboarding {
    internal enum Analytics {
      /// Подробные отчеты
      /// Графики и диаграммы
      internal static let description = L10n.tr("Localizable", "onboarding.analytics.description", fallback: "Подробные отчеты\nГрафики и диаграммы")
    }
    internal enum Notifications {
      /// Создавайте собственные
      /// напоминания для разных ситуаций
      internal static let description = L10n.tr("Localizable", "onboarding.notifications.description", fallback: "Создавайте собственные\nнапоминания для разных ситуаций")
    }
    internal enum Templates {
      /// Создавайте шаблоны
      /// для регулярных трат
      internal static let description = L10n.tr("Localizable", "onboarding.templates.description", fallback: "Создавайте шаблоны\nдля регулярных трат")
    }
    internal enum Welcome {
      /// Удобная статистика
      /// Создание счетов
      /// Собственные категории
      internal static let description = L10n.tr("Localizable", "onboarding.welcome.description", fallback: "Удобная статистика\nСоздание счетов\nСобственные категории")
      /// ===== ONBOARDING =====
      internal static let title = L10n.tr("Localizable", "onboarding.welcome.title", fallback: "Управляйте своими\nфинансами с легкостью!")
    }
  }
  internal enum Period {
    /// ===== PERIODS =====
    internal static let day = L10n.tr("Localizable", "period.day", fallback: "День")
    /// Месяц
    internal static let month = L10n.tr("Localizable", "period.month", fallback: "Месяц")
    /// Период
    internal static let title = L10n.tr("Localizable", "period.title", fallback: "Период")
    /// Неделя
    internal static let week = L10n.tr("Localizable", "period.week", fallback: "Неделя")
    /// Год
    internal static let year = L10n.tr("Localizable", "period.year", fallback: "Год")
  }
  internal enum Pin {
    /// Осталось попыток: %d
    internal static func attemptsLeft(_ p1: Int) -> String {
      return L10n.tr("Localizable", "pin.attempts_left", p1, fallback: "Осталось попыток: %d")
    }
    /// Войти с помощью Face ID
    internal static let bimetricReason = L10n.tr("Localizable", "pin.bimetric_reason", fallback: "Войти с помощью Face ID")
    /// Введите новый PIN-код
    internal static let changeNew = L10n.tr("Localizable", "pin.change_new", fallback: "Введите новый PIN-код")
    /// Введите текущий PIN-код для подтверждения
    internal static let confirmCurrentPlaceholder = L10n.tr("Localizable", "pin.confirm_current_placeholder", fallback: "Введите текущий PIN-код для подтверждения")
    /// Повторно введенный PIN-код содержит ошибку
    internal static let confirmError = L10n.tr("Localizable", "pin.confirm_error", fallback: "Повторно введенный PIN-код содержит ошибку")
    /// Повторите введенный PIN-код для подтверждения
    internal static let confirmPlaceholder = L10n.tr("Localizable", "pin.confirm_placeholder", fallback: "Повторите введенный PIN-код для подтверждения")
    /// ===== PIN =====
    internal static let createRequired = L10n.tr("Localizable", "pin.create_required", fallback: "Для входа в приложение требуется создать PIN-код")
    /// Введите PIN-код
    internal static let enterPlaceholder = L10n.tr("Localizable", "pin.enter_placeholder", fallback: "Введите PIN-код")
    /// Забыли PIN-код?
    internal static let forgotTitle = L10n.tr("Localizable", "pin.forgot_title", fallback: "Забыли PIN-код?")
    /// Неверный PIN
    internal static let incorrect = L10n.tr("Localizable", "pin.incorrect", fallback: "Неверный PIN")
    /// Ввести PIN-код
    internal static let localizedFallbackTitle = L10n.tr("Localizable", "pin.localized_fallback_title", fallback: "Ввести PIN-код")
    /// Приложение заблокировано на %d секунд из-за слишком частых попыток
    internal static func locked(_ p1: Int) -> String {
      return L10n.tr("Localizable", "pin.locked", p1, fallback: "Приложение заблокировано на %d секунд из-за слишком частых попыток")
    }
    /// PIN не совпадают
    internal static let mismatch = L10n.tr("Localizable", "pin.mismatch", fallback: "PIN не совпадают")
    /// Ошибка сохранения PIN
    internal static let saveError = L10n.tr("Localizable", "pin.save_error", fallback: "Ошибка сохранения PIN")
    /// PIN-код успешно создан
    internal static let successCreated = L10n.tr("Localizable", "pin.success_created", fallback: "PIN-код успешно создан")
  }
  internal enum TransactionCategories {
    /// Одежда
    internal static let clothes = L10n.tr("Localizable", "transaction_categories.clothes", fallback: "Одежда")
    /// ===== TRANSACTION CATEGORIES =====
    internal static let health = L10n.tr("Localizable", "transaction_categories.health", fallback: "Здоровье")
    /// Квартира и ЖКХ
    internal static let housing = L10n.tr("Localizable", "transaction_categories.housing", fallback: "Квартира и ЖКХ")
    /// Досуг
    internal static let leisure = L10n.tr("Localizable", "transaction_categories.leisure", fallback: "Досуг")
    /// Другое
    internal static let other = L10n.tr("Localizable", "transaction_categories.other", fallback: "Другое")
    /// Продукты
    internal static let products = L10n.tr("Localizable", "transaction_categories.products", fallback: "Продукты")
  }
  internal enum Transactions {
    internal enum Add {
      /// ===== TRANSACTIONS =====
      internal static let amountZero = L10n.tr("Localizable", "transactions.add.amount_zero", fallback: "0")
      /// Комментарий...
      internal static let descriptionPlaceholder = L10n.tr("Localizable", "transactions.add.description_placeholder", fallback: "Комментарий...")
    }
    internal enum Templates {
      /// Список шаблонов пуст. Добавьте новые шаблоны, чтобы упростить добавление регулярных операций.
      internal static let empty = L10n.tr("Localizable", "transactions.templates.empty", fallback: "Список шаблонов пуст. Добавьте новые шаблоны, чтобы упростить добавление регулярных операций.")
      /// Шаблоны — это готовые
      /// повторяющиеся операции
      internal static let info = L10n.tr("Localizable", "transactions.templates.info", fallback: "Шаблоны — это готовые\nповторяющиеся операции")
      /// Шаблоны операций
      internal static let title = L10n.tr("Localizable", "transactions.templates.title", fallback: "Шаблоны операций")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
