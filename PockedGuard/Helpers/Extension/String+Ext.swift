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
            case appName
            case today
            case period
            case cancel
            case resume
            case done
            case edit
            case delete
            case ok
            case income
            case expenses
            case accountTitle
            case total
            case transactionsEmptyLabel
            case categoriesTitle
            case categoryLabelTitle
            case templatesLabelTitle
            case accountLabelTitle
            case RUB
            case USD
            case EUR
            case icon
            case amount
            case still
            case wrap
            case replace
            case analytics
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
            case edit
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
            case amountZeroPlaceholder
            case descriptionPlaceholder
            case templatesTitle
            case templatesInfo
            case templatesIsEmptyLabel
            case addCategory
            case editCategory
            case addAccount
            case editAccount
            case addTemplate
            case editTemplate
            case accountNameLabel
            case accountNamePlaceholder
            case accountCurrencyType
            case categoryNameLabel
            case categoryNamePlaceholder
            case colorCategoryTitle
            case amountPlaceholder
            case setupIsPrimary
            case templateAmountInfo
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
            case insufficientFunds
            case categoryNotSelectedError
            case invalidNameAccount
            case invalidNameCategory
            case emptyCategoryColor
            case emptyTemplateIcon
            case emptyTemplateCategoryOrAmount
            case duplicateCategoryName
            case duplicateAccountName
        }
        
        enum Alert {
            case systemCategoryTitle
            case systemCategoryMessage
            case addColorMessage
            case duplicateTemplateIconTitle
            case duplicateTemplateIconMessage
            case primaryAccountTitle
            case primaryAccountMessage
        }
        
        enum Onboarding {
            case welcomeTitle
            case welcomeDescription
            case analyticsDescription
            case templatesDescription
            case notificationDescription
        }
    }
}

// MARK: - Common
extension String.Localized.Common: Localizable {
    var key: String {
        switch self {
        case .appName: return "AppName"
        case .today: return "Today"
        case .period: return "Period"
        case .cancel: return "Cancel"
        case .resume: return "Continue"
        case .done: return "Done"
        case .edit: return "Edit"
        case .delete: return "Delete"
        case .ok: return "OK"
        case .income: return "Income"
        case .expenses: return "Expenses"
        case .accountTitle: return "DefaultAccountTitle"
        case .total: return "Total"
        case .transactionsEmptyLabel: return "Transaction.EmptyLabel"
        case .categoriesTitle: return "Categories.Title"
        case .categoryLabelTitle: return "Categories.CategoryLabelTitle"
        case .templatesLabelTitle: return "Categories.TemplatesLabelTitle"
        case .accountLabelTitle: return "Categories.AccountLabelTitle"
        case .RUB: return "Currency.RUB"
        case .USD: return "Currency.USD"
        case .EUR: return "Currency.EUR"
        case .icon: return "Icon"
        case .amount: return "Amount"
        case .still: return "Still"
        case .wrap: return "Wrap"
        case .replace: return "Replace"
        case .analytics: return "Analytics"
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
        case .edit: return "NotificationScreen.Edit.Title"
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
        case .amountZeroPlaceholder: return "AddScreen.AmountZeroPlaceholder"
        case .descriptionPlaceholder: return "AddScreen.DescriptionPlaceholder"
        case .templatesTitle: return "AddScreen.TemplatesLabelTitle"
        case .templatesInfo: return "AddScreen.TemplatesInfoLabel"
        case .templatesIsEmptyLabel: return "AddScreen.TemplatesIsEmptyLabel"
        case .addCategory: return "Add.Category"
        case .editCategory: return "Add.EditCategory"
        case .addAccount: return "Add.Account"
        case .editAccount: return "Add.EditAccount"
        case .addTemplate: return "Add.Template"
        case .editTemplate: return "Add.EditTemplate"
        case .accountNameLabel: return  "Add.AccountNameLabel"
        case .accountNamePlaceholder: return "Add.AccountNamePlaceholder"
        case .accountCurrencyType: return "Add.CurrencyType"
        case .categoryNameLabel: return "Add.CategoryNameLabel"
        case .categoryNamePlaceholder: return "Add.CategoryNamePlaceholder"
        case .colorCategoryTitle: return "Add.ColorCategoryTitle"
        case .amountPlaceholder: return "Add.AmountPlaceholder"
        case .setupIsPrimary: return "Add.SetupIsPrimary"
        case .templateAmountInfo: return "Add.TemplateAmountInfo"
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
        case .insufficientFunds: return "Error.InsufficientFunds"
        case .categoryNotSelectedError: return "Error.CategoryNotSelectedError"
        case .invalidNameAccount: return "Error.InvalidNameAccount"
        case .invalidNameCategory: return "Error.InvalidNameCategory"
        case .emptyCategoryColor: return "Error.EmptyCategoryColor"
        case .emptyTemplateIcon: return "Error.EmptyTemplateIcon"
        case .emptyTemplateCategoryOrAmount: return "Error.EmptyTemplateCategoryOrAmount"
        case .duplicateCategoryName: return "Error.DuplicateCategoryName"
        case .duplicateAccountName: return "Error.DuplicateAccountName"
        }
    }
}

// MARK: - Alert
extension String.Localized.Alert: Localizable {
    var key: String {
        switch self {
        case .systemCategoryTitle: return "Alert.SystemCategoryTitle"
        case .systemCategoryMessage: return "Alert.SystemCategoryMessage"
        case .addColorMessage: return "Alert.AddColorMessage"
        case .duplicateTemplateIconTitle: return "Alert.DuplicateTemplateIconTitle"
        case .duplicateTemplateIconMessage: return "Alert.DuplicateTemplateIconMessage"
        case .primaryAccountTitle: return "Alert.PrimaryAccountTitle"
        case .primaryAccountMessage: return "Alert.PrimaryAccountMessage"
        }
    }
}

// MARK: - Onboarding
extension String.Localized.Onboarding: Localizable {
    var key: String {
        switch self {
        case .welcomeTitle: return "Onboarding.WelcomeTitle"
        case .welcomeDescription: return "Onboarding.WelcomeDescription"
        case .analyticsDescription: return "Onboarding.AnalyticsDescription"
        case .templatesDescription: return "Onboarding.TemplatesDescription"
        case .notificationDescription: return "Onboarding.NotificationDescription"
        }
    }
}
