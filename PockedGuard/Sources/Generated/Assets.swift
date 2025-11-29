// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let accentColor = ColorAsset(name: "AccentColor")
  internal static let appBackground = ColorAsset(name: "appBackground")
  internal static let appCardAndField = ColorAsset(name: "appCardAndField")
  internal static let appCardFieldSecondary = ColorAsset(name: "appCardFieldSecondary")
  internal static let appErrorRed = ColorAsset(name: "appErrorRed")
  internal static let appExpense = ColorAsset(name: "appExpense")
  internal static let appForeground = ColorAsset(name: "appForeground")
  internal static let appForegroundSecondary = ColorAsset(name: "appForegroundSecondary")
  internal static let appGradientOne = ColorAsset(name: "appGradientOne")
  internal static let appGradientTwo = ColorAsset(name: "appGradientTwo")
  internal static let appIncome = ColorAsset(name: "appIncome")
  internal static let appLoss = ColorAsset(name: "appLoss")
  internal static let appMainBlue = ColorAsset(name: "appMainBlue")
  internal static let appMaterialsUltrathinDark = ColorAsset(name: "appMaterialsUltrathinDark")
  internal static let appSelectedBlue = ColorAsset(name: "appSelectedBlue")
  internal static let appSeparatorColor = ColorAsset(name: "appSeparatorColor")
  internal static let icon1 = ImageAsset(name: "icon1")
  internal static let icon10 = ImageAsset(name: "icon10")
  internal static let icon2 = ImageAsset(name: "icon2")
  internal static let icon3 = ImageAsset(name: "icon3")
  internal static let icon4 = ImageAsset(name: "icon4")
  internal static let icon5 = ImageAsset(name: "icon5")
  internal static let icon6 = ImageAsset(name: "icon6")
  internal static let icon7 = ImageAsset(name: "icon7")
  internal static let icon8 = ImageAsset(name: "icon8")
  internal static let icon9 = ImageAsset(name: "icon9")
  internal static let remindingIcon = ImageAsset(name: "remindingIcon")
  internal static let onboardingWelcome = ImageAsset(name: "OnboardingWelcome")
  internal static let backgroundOnboardingAnalytics = ImageAsset(name: "backgroundOnboardingAnalytics")
  internal static let backgroundOnboardingNotification = ImageAsset(name: "backgroundOnboardingNotification")
  internal static let backgroundOnboardingTemplates = ImageAsset(name: "backgroundOnboardingTemplates")
  internal static let backgroundOnboardingWelcome = ImageAsset(name: "backgroundOnboardingWelcome")
  internal static let chartOnboardingAnalytics = ImageAsset(name: "chartOnboardingAnalytics")
  internal static let diagramOnboardingAnalytics = ImageAsset(name: "diagramOnboardingAnalytics")
  internal static let notificationOnboarding = ImageAsset(name: "notificationOnboarding")
  internal static let pockedGuard = ImageAsset(name: "pockedGuard")
  internal static let templateOnboarding = ImageAsset(name: "templateOnboarding")
  internal static let addIcon = ImageAsset(name: "AddIcon")
  internal static let analitycsIcon = ImageAsset(name: "AnalitycsIcon")
  internal static let categoriesIcon = ImageAsset(name: "CategoriesIcon")
  internal static let homeIcon = ImageAsset(name: "HomeIcon")
  internal static let profileIcon = ImageAsset(name: "ProfileIcon")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal private(set) lazy var swiftUIColor: SwiftUI.Color = {
    SwiftUI.Color(asset: self)
  }()
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Color {
  init(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

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
