//
//  String+Ext.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 25.06.2025.
//

import Foundation

protocol Localizable {
    var key: String { get }
}

extension Localizable {
    var localized: String {
        NSLocalizedString(key, comment: "")
    }
}

extension String {
    enum Localized {
        enum Common {
            case today
            case period
            case cancel
            case done
            case edit
            case delete
            case ok
            case income
            case expenses
            case accountTitle
            case total
            case transactionsEmptyLabel 
        }
        
        enum Month {
            case january
            case february
            case march
            case april
            case may
            case june
            case july
            case august
            case september
            case october
            case november
            case december
        }
        
        enum Period {
            case day, week, month
        }
        
        enum Notification {
            case title
            case createTitle
            case reminderTitle
            case titlePlaceholder
            case textPlaceholder
            case reminderText
            case frequency
            case time
            case startDate
            case everyWeek
            case everyMonth
            case everyDay
            case once
            case emptyLabel
        }
        
        enum Add {
            case amountPlaceholder
            case descriptionPlaceholder
            case templatesTitle
            case categoryTitle
            case templatesInfo
            case categoryNotSelectedError
        }
        
        enum TransactionCategories {
            case health
            case products
            case clothes
            case leisure
            case housing
            case other
        }
        
        enum IncomeCategories {
            case salary
            case investments
            case gifts
            case otherIncome
        }
        
        enum Error {
            case title
            case textFieldIsEmpty
            case unknown
            case accountEmpty
            case templatesEmpty
            case categoriesEmpty
            case titleEmpty
            case descriptionEmpty
            case amountError
            case notificationUpdateFailed
            case notificationSchedulingFailed
            case notificationFetchFailed
            case notificationDeleteFailed
            case failedToCreateDefaultData
            case transactionFetchFailed
            case accountFetchFailed
            case dataFetchFailed

        }
    }
}

// MARK: - Common
extension String.Localized.Common: Localizable {
    var key: String {
        switch self {
        case .today: return "Today"
        case .period: return "Period"
        case .cancel: return "Cancel"
        case .done: return "Done"
        case .edit: return "Edit"
        case .delete: return "Delete"
        case .ok: return "OK"
        case .income: return "Income"
        case .expenses: return "Expenses"
        case .accountTitle: return "DefaultAccountTitle"
        case .total: return "Total"
        case .transactionsEmptyLabel: return "Transaction.EmptyLabel"
        }
    }
}

// MARK: - Month
extension String.Localized.Month: Localizable {
    var key: String {
        switch self {
        case .january: return "Month.January"
        case .february: return "Month.February"
        case .march: return "Month.March"
        case .april: return "Month.April"
        case .may: return "Month.May"
        case .june: return "Month.June"
        case .july: return "Month.July"
        case .august: return "Month.August"
        case .september: return "Month.September"
        case .october: return "Month.October"
        case .november: return "Month.November"
        case .december: return "Month.December"
        }
    }
}

// MARK: - Period
extension String.Localized.Period: Localizable {
    var key: String {
        switch self {
        case .day: return "Period.Day"
        case .week: return "Period.Week"
        case .month: return "Period.Month"
        }
    }
}

// MARK: - Notification
extension String.Localized.Notification: Localizable {
    var key: String {
        switch self {
        case .title: return "NotificationScreen.Title"
        case .createTitle: return "NotificationScreen.Create.Title"
        case .reminderTitle: return "NotificationScreen.ReminderTitle"
        case .titlePlaceholder: return "NotificationScreen.TitlePlaceholder"
        case .textPlaceholder: return "NotificationScreen.TextPlaceholder"
        case .reminderText: return "NotificationScreen.ReminderText"
        case .frequency: return "NotificationScreen.Frequency"
        case .time: return "NotificationScreen.Time"
        case .startDate: return "NotificationScreen.StartDate"
        case .everyWeek: return "NotificationScreen.EveryWeek"
        case .everyMonth: return "NotificationScreen.EveryMonth"
        case .everyDay: return "NotificationScreen.EveryDay"
        case .once: return "NotificationScreen.Once"
        case .emptyLabel: return "NotificationScreen.EmptyLabel"
        }
    }
}

// MARK: - Add
extension String.Localized.Add: Localizable {
    var key: String {
        switch self {
        case .amountPlaceholder: return "AddScreen.AmountPlaceholder"
        case .descriptionPlaceholder: return "AddScreen.DescriptionPlaceholder"
        case .templatesTitle: return "AddScreen.TemplatesLabelTitle"
        case .categoryTitle: return "AddScreen.CategoryLabelTitle"
        case .templatesInfo: return "AddScreen.TemplatesInfoLabel"
        case .categoryNotSelectedError: return "AddScreen.CategoryNotSelectedError"
        }
    }
}

// MARK: - Transaction Categories
extension String.Localized.TransactionCategories: Localizable {
    var key: String {
        switch self {
        case .health: return "TransactionCategories.Health"
        case .products: return "TransactionCategories.Products"
        case .clothes: return "TransactionCategories.Clothes"
        case .leisure: return "TransactionCategories.Leisure"
        case .housing: return "TransactionCategories.Housing"
        case .other: return "TransactionCategories.Other"
        }
    }
}

// MARK: - Income Categories
extension String.Localized.IncomeCategories: Localizable {
    var key: String {
        switch self {
        case .salary: return "IncomeCategories.Salary"
        case .investments: return "IncomeCategories.Investments"
        case .gifts: return "IncomeCategories.Gifts"
        case .otherIncome: return "IncomeCategories.OtherIncome"
        }
    }
}

// MARK: - Error
extension String.Localized.Error: Localizable {
    var key: String {
        switch self {
        case .title: return "Error.Title"
        case .textFieldIsEmpty: return "Error.TextFieldIsEmpty"
        case .unknown: return "Error.Unknown"
        case .accountEmpty: return "Error.AccountEmpty"
        case .templatesEmpty: return "Error.TemplatesEmpty"
        case .categoriesEmpty: return "Error.CategoriesEmpty"
        case .titleEmpty: return "Error.TitleEmpty"
        case .descriptionEmpty: return "Error.DescriptionEmpty"
        case .amountError: return "Error.Amount"
        case .notificationUpdateFailed: return "Error.NotificationUpdateFailed"
        case .notificationSchedulingFailed: return "Error.NotificationSchedulingFailed"
        case .notificationFetchFailed: return "Error.NotificationFetchFailed"
        case .notificationDeleteFailed: return "Error.NotificationDeleteFailed"
        case .failedToCreateDefaultData: return "Error.FailedToCreateDefaultData"
        case .transactionFetchFailed: return "Error.TransactionFetchFailed"
        case .accountFetchFailed: return "Error.AccountFetchFailed"
        case .dataFetchFailed: return "Error.DataFetchFailed"
        }
    }
}
