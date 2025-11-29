//
//  PinKeyboardView.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 21.11.2025.
//

import SwiftUI
import RxSwift

struct PinKeyboardView: View {
    // MARK: - Public properties
    let digitSubject: PublishSubject<String> = .init()
    let biometricSubject: PublishSubject<Void> = .init()
    let deleteSubject: PublishSubject<Void> = .init()
    let heightSubject: BehaviorSubject<CGFloat> = .init(value: .zero)
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            let buttonSize: CGFloat = calculateButtonSize(for: geometry.size.width)
            let height: CGFloat = calculateHeight(for: buttonSize)
            
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible(), spacing: Constants.Layout.horizontalSpacing),
                    count: Constants.Layout.gridItemCount
                ),
                spacing: Constants.Layout.verticalSpacing) {
                    ForEach(Constants.KeyType.buttonMatix.flatMap{$0}, id: \.self) { buttonType in
                        buttonView(for: buttonType, size: buttonSize)
                    }
                }
                .padding(.horizontal, Constants.Layout.horizontalPadding)
                .frame(maxHeight: .infinity)
                .onChange(of: height) { oldValue, newValue in
                    if oldValue != newValue {
                        heightSubject.onNext(newValue)
                    }
                }
        }
    }
}

// MARK: - Static methods
extension PinKeyboardView {
    static func calculateHeight(for widthScreen: CGFloat) -> CGFloat {
        let totalHorizontalPadding: CGFloat = Constants.Layout.horizontalPadding * 2
        let totalHorizontalSpacing: CGFloat = Constants.Layout.horizontalSpacing * 2
        let buttonSize = (widthScreen - totalHorizontalPadding - totalHorizontalSpacing) / CGFloat(Constants.Layout.gridItemCount)
        
        let verticalSpacing: CGFloat = Constants.Layout.verticalSpacing
        let totalVerticalSpacing = verticalSpacing * (Constants.Layout.rowCount - 1)
        
        return buttonSize * Constants.Layout.rowCount + totalVerticalSpacing
    }
}

// MARK: - Private methods
private extension PinKeyboardView {
    func calculateButtonSize(for width: CGFloat) -> CGFloat {
        let totalHorizontalPadding: CGFloat = Constants.Layout.horizontalPadding * 2
        let totalHorizontalSpacing: CGFloat = Constants.Layout.horizontalSpacing * 2
        let availableWidth = width - totalHorizontalPadding - totalHorizontalSpacing
        return availableWidth / CGFloat(Constants.Layout.gridItemCount)
    }
    
    func calculateHeight(for buttonSize: CGFloat) -> CGFloat {
        let totalButtonHeight: CGFloat = buttonSize * CGFloat(Constants.KeyType.buttonMatix.count)
        let totalVerticalSpacing: CGFloat = Constants.Layout.verticalSpacing * CGFloat(Constants.KeyType.buttonMatix.count - 1)
        
        let keyboardHeight: CGFloat = totalButtonHeight + totalVerticalSpacing
        return keyboardHeight
    }
    
    @ViewBuilder
    func buttonView(for buttonType: Constants.KeyType, size: CGFloat) -> some View {
        switch buttonType {
        case .delete, .biometrics:
            Button {
                handleButtonTap(buttonType)
            } label: {
                buttonContentView(for: buttonType, size: size)
            }
            .buttonStyle(CustomOutlineButtonStyle())
        case .digit:
            Button {
                handleButtonTap(buttonType)
            } label: {
                buttonContentView(for: buttonType, size: size)
            }
            .buttonStyle(CustomFilledButtonStyle())
        }
    }
    
    @ViewBuilder
    func buttonContentView(for buttonType: Constants.KeyType, size: CGFloat) -> some View {
        Group {
            switch buttonType {
            case .digit(let value):
                Text(value)
                    .font(.title2)
                    .fontWeight(.regular)
            case .delete:
                Image(systemName: "delete.left")
                    .font(.title)
            case .biometrics:
                Image(systemName: "faceid")
                    .font(.title)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: size)
    }
    
    func handleButtonTap(_ buttonType: Constants.KeyType) {
        buttonType.isDigit ? Haptics.medium() : Haptics.selection()
        
        switch buttonType {
        case .biometrics:
            biometricSubject.onNext(())
        case .delete:
            deleteSubject.onNext(())
        case .digit(let value):
            digitSubject.onNext(value)
        }
    }
}

// MARK: - Constants
private enum Constants {
    enum Layout {
        static let verticalSpacing: CGFloat = 16
        static let horizontalSpacing: CGFloat = 24
        static let gridItemCount: Int = 3
        static let horizontalPadding: CGFloat = 52
        static let rowCount: CGFloat = 4
    }
    
    enum KeyType: Hashable {
        case digit(String)
        case delete
        case biometrics
        
        var rawValue: String {
            switch self {
            case .digit(let value):
                return value
            case .delete:
                return "delete"
            case .biometrics:
                return "biometrics"
            }
        }
        
        var digitValue: String? {
            if case .digit(let value) = self { return value }
            return nil
        }
        
        var isDigit: Bool { digitValue != nil}
        
        static let buttonMatix: [[KeyType]] = [
            [.digit("1"), .digit("2"), .digit("3")],
            [.digit("4"), .digit("5"), .digit("6")],
            [.digit("7"), .digit("8"), .digit("9")],
            [.biometrics, .digit("0"), .delete]
        ]
    }
}
