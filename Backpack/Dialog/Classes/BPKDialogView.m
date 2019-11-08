/*
 * Backpack - Skyscanner's Design System
 *
 * Copyright 2018-2019 Skyscanner Ltd
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "BPKDialogView.h"

#import <Backpack/Button.h>
#import <Backpack/Color.h>
#import <Backpack/Common.h>
#import <Backpack/Label.h>
#import <Backpack/Radii.h>
#import <Backpack/Shadow.h>
#import <Backpack/Spacing.h>

#import "BPKDialogIconDefinition.h"
#import "BPKDialogIconView.h"

NS_ASSUME_NONNULL_BEGIN
@interface BPKActionButtonPair : NSObject
@property(nonatomic, strong) BPKDialogButtonAction *action;
@property(nonatomic, weak) BPKButton *button;
@property(readonly, nonatomic) BOOL hasIcon;
@property(readonly, nonatomic) BOOL hasFlareView;
@end

@implementation BPKActionButtonPair
@end

@interface BPKDialogView ()

@property(nonatomic, strong, nullable) BPKDialogIconView *iconView;

@property(nonatomic, strong) UIView *contentView;
@property(nonatomic, strong, nullable) BPKLabel *titleLabel;
@property(nonatomic, strong) BPKLabel *descriptionLabel;
@property(nonatomic, strong) UIStackView *buttonStackView;
@property(nullable, nonatomic, strong) BPKFlareView *flareView;

@property(nonatomic, strong) NSMutableArray<BPKActionButtonPair *> *registeredActions;
@property(nonatomic, strong) NSLayoutConstraint *descriptionLabelTopConstraint;
@property(nonatomic, strong) NSLayoutConstraint *titleLabelTopConstraint;
@property(nonatomic, strong) UIColor *dialogContentViewBackgroundColor;
@end

@implementation BPKDialogView

- (instancetype)initWithTitle:(NSString *_Nullable)title
                      message:(NSString *)message
               iconDefinition:(BPKDialogIconDefinition *_Nullable)iconDefinition
                    flareView:(BPKFlareView *_Nullable)flareView {
    BPKAssertMainThread();
    self = [super initWithFrame:CGRectZero];

    if (self) {
        self.registeredActions = [NSMutableArray new];

        self.flareView = flareView;

        [self setupViews];
        [self addViews];
        [self setupConstraints];

        self.title = title;
        self.message = message;
        self.iconDefinition = iconDefinition;
        self.buttonSize = BPKButtonSizeLarge;
    }

    return self;
}

- (BOOL)hasIcon {
    return self.iconDefinition != nil;
}

- (BOOL)hasFlareView {
    return self.flareView != nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    BPKAssertMainThread();
    self = [super initWithFrame:frame];

    if (self) {
        self.registeredActions = [NSMutableArray new];
        self.buttonSize = BPKButtonSizeLarge;

        [self setupViews];
        [self addViews];
        [self setupConstraints];
    }

    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    BPKAssertMainThread();
    self = [super initWithCoder:aDecoder];

    if (self) {
        self.registeredActions = [NSMutableArray new];
        self.buttonSize = BPKButtonSizeLarge;

        [self setupViews];
        [self addViews];
        [self setupConstraints];
    }

    return self;
}

- (void)setupViews {
    self.contentView = [UIView new];
    self.contentView.backgroundColor = self.dialogContentViewBackgroundColor;
    self.contentView.layer.cornerRadius = BPKBorderRadiusSm;

    self.titleLabel = [[BPKLabel alloc] initWithFontStyle:BPKFontStyleTextXlEmphasized];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textColor = BPKColor.textPrimaryColor;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;

    self.descriptionLabel = [[BPKLabel alloc] initWithFontStyle:BPKFontStyleTextLg];
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;

    self.buttonStackView = [[UIStackView alloc] initWithFrame:CGRectZero];
    self.buttonStackView.axis = UILayoutConstraintAxisVertical;
    self.buttonStackView.spacing = BPKSpacingMd;

    self.buttonStackView.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;

    self.contentView.clipsToBounds = YES;
}

- (void)addViews {
    [self addSubview:self.contentView];

    if (self.hasFlareView) {
        self.flareView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.flareView];
    }

    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.descriptionLabel];
    [self.contentView addSubview:self.buttonStackView];
}

- (void)setLayoutMargins {
    CGFloat bottomMargin = BPKSpacingMd;
    if (self.style == BPKDialogControllerStyleAlert && self.registeredActions.count > 0) {
        bottomMargin = self.hasIcon || self.hasFlareView ? BPKSpacingLg : BPKSpacingBase;
    }
    self.contentView.layoutMargins =
        UIEdgeInsetsMake(self.contentView.layoutMargins.top, BPKSpacingLg, bottomMargin, BPKSpacingLg);
}

- (void)setupConstraints {
    [self setLayoutMargins];
    self.descriptionLabelTopConstraint =
        [self.descriptionLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:BPKSpacingMd];

    NSLayoutConstraint *titleLabelTopConstraint;
    if (self.hasFlareView) {
        [self setupFlareViewConstraints];
        titleLabelTopConstraint =
            [self.titleLabel.topAnchor constraintGreaterThanOrEqualToAnchor:self.flareView.bottomAnchor
                                                                   constant:BPKSpacingBase];
    } else {
        titleLabelTopConstraint =
            [self.titleLabel.topAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.topAnchor
                                                                   constant:BPKSpacingBase];
    }

    [NSLayoutConstraint activateConstraints:@[
        titleLabelTopConstraint,

        [self.contentView.topAnchor constraintGreaterThanOrEqualToAnchor:self.topAnchor],

        [self.contentView.superview.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.contentView.superview.leadingAnchor],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.contentView.superview.trailingAnchor],

        [self.titleLabel.centerXAnchor constraintEqualToAnchor:self.titleLabel.superview.centerXAnchor],
        [self.titleLabel.leadingAnchor
            constraintEqualToAnchor:self.titleLabel.superview.layoutMarginsGuide.leadingAnchor],
        [self.titleLabel.superview.layoutMarginsGuide.trailingAnchor
            constraintEqualToAnchor:self.titleLabel.trailingAnchor],

        self.descriptionLabelTopConstraint,
        [self.descriptionLabel.leadingAnchor
            constraintEqualToAnchor:self.descriptionLabel.superview.layoutMarginsGuide.leadingAnchor],
        [self.descriptionLabel.superview.layoutMarginsGuide.trailingAnchor
            constraintEqualToAnchor:self.descriptionLabel.trailingAnchor],

        [self.buttonStackView.topAnchor constraintEqualToAnchor:self.descriptionLabel.bottomAnchor
                                                       constant:BPKSpacingLg],
        [self.buttonStackView.leadingAnchor
            constraintEqualToAnchor:self.buttonStackView.superview.layoutMarginsGuide.leadingAnchor
                           constant:(BPKSpacingXl - BPKSpacingLg)],
        [self.buttonStackView.superview.layoutMarginsGuide.trailingAnchor
            constraintEqualToAnchor:self.buttonStackView.trailingAnchor
                           constant:(BPKSpacingXl - BPKSpacingLg)],
        [self.buttonStackView.superview.layoutMarginsGuide.bottomAnchor
            constraintEqualToAnchor:self.buttonStackView.bottomAnchor]
    ]];
}

- (void)updateIconView {
    if (self.hasIcon && self.iconView == nil) {
        self.iconView = [[BPKDialogIconView alloc] initWithIconDefinition:self.iconDefinition];
        self.iconView.backgroundColor = self.dialogContentViewBackgroundColor;
        [self addSubview:self.iconView];

        CGSize iconViewSize = [[self.iconView class] viewSize];
        [NSLayoutConstraint activateConstraints:@[
            [self.iconView.topAnchor constraintEqualToAnchor:self.iconView.superview.topAnchor],
            [self.iconView.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],

            [self.contentView.topAnchor constraintGreaterThanOrEqualToAnchor:self.iconView.bottomAnchor
                                                                    constant:-(iconViewSize.height / 2.0)],

            // NOTE: The constant here is explicitly not BPKSpacingLg because the icon view has a white border which
            // blends with the contentView background. Using BPKSpacingLg makes it look unaligned with the BPKSpacingLg
            // below. The border is BPKSpacingMd wide which when added to BPKSpacingBase makes it BPKSpacingLg. This
            // ligns up nicely with the BPKSpacingLg between descriptionLabel and buttonStackView
            [self.titleLabel.topAnchor constraintGreaterThanOrEqualToAnchor:self.iconView.bottomAnchor
                                                                   constant:BPKSpacingBase]
        ]];

        [self updateTopAnchorConstraint];
    }

    if (!self.hasIcon && self.iconView != nil) {
        [self.iconView removeFromSuperview];
        _iconView = nil;
    }

    if (self.iconDefinition && self.iconView != nil) {
        self.iconView.iconDefinition = self.iconDefinition;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    // Calculated path including circular icon view
    CGRect layerRect = self.contentView.layer.frame;
    CGMutablePathRef shadowPath = CGPathCreateMutable();
    CGPathAddRoundedRect(shadowPath, nil, layerRect, self.contentView.layer.cornerRadius,
                         self.contentView.layer.cornerRadius);
    if (self.hasIcon) {
        CGRect iconViewRect = self.iconView.layer.frame;
        CGPathAddRoundedRect(shadowPath, nil, iconViewRect, iconViewRect.size.width / 2.0,
                             iconViewRect.size.height / 2.0);
    }

    [[BPKShadow shadowLg] applyToLayer:self.layer];
    CGPathRef finalPath = CGPathCreateCopy(shadowPath);
    self.layer.shadowPath = finalPath;

    CGPathRelease(finalPath);
    CGPathRelease(shadowPath);
}

- (void)buttonTapped:(BPKButton *)button {
    BPKDialogButtonAction *action = [self actionForButton:button];
    if (action) {
        [self.delegate didInvokeButtonAction:action];
    }
}

- (BPKDialogButtonAction *_Nullable)actionForButton:(BPKButton *)button {
    for (BPKActionButtonPair *pair in self.registeredActions) {
        if (pair.button == button) {
            return pair.action;
        }
    }

    return nil;
}

#pragma mark - Public

#pragma mark - Property overrides

- (void)setButtonSize:(BPKButtonSize)buttonSize {
    if (_buttonSize != buttonSize) {
        _buttonSize = buttonSize;

        for (BPKActionButtonPair *buttonActionPair in self.registeredActions) {
            buttonActionPair.button.size = buttonSize;
        }
    }
}

- (void)setCornerStyle:(BPKDialogCornerStyle)cornerStyle {
    if (_cornerStyle != cornerStyle) {
        _cornerStyle = cornerStyle;

        self.contentView.layer.cornerRadius =
            cornerStyle == BPKDialogCornerStyleLarge ? BPKBorderRadiusLg : BPKBorderRadiusSm;
    }
}

- (void)setIconDefinition:(BPKDialogIconDefinition *_Nullable)iconDefinition {
    BPKAssertMainThread();
    if (iconDefinition != _iconDefinition) {
        // Can't show an icon and a flare view:
        _iconDefinition = self.flareView == nil ? iconDefinition : nil;
        [self updateIconView];
        [self setLayoutMargins];
    }
}

- (void)setTitle:(NSString *_Nullable)title {
    BPKAssertMainThread();
    self.titleLabel.text = title;
    [self updateTopAnchorConstraint];
}

- (NSString *_Nullable)title {
    return self.titleLabel.text;
}

- (void)setMessage:(NSString *_Nullable)description {
    BPKAssertMainThread();
    self.descriptionLabel.text = description;
}

- (NSString *_Nullable)message {
    return self.descriptionLabel.text;
}

- (void)setStyle:(BPKDialogControllerStyle)style {
    if (_style != style) {
        _style = style;

        [self setLayoutMargins];
    }
}

#pragma mark - Other public methods

- (void)addButtonAction:(BPKDialogButtonAction *)action {
    BPKAssertMainThread();
    BPKButton *button = [[BPKButton alloc] initWithSize:self.buttonSize style:action.style];
    [button setTitle:action.title];
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonStackView addArrangedSubview:button];

    BPKActionButtonPair *pair = [[BPKActionButtonPair alloc] init];
    pair.button = button;
    pair.action = action;
    [self.registeredActions addObject:pair];
    [self setLayoutMargins];
}

#pragma mark - Private methods

// This method helps us to set up the correct top anchor margin depending if we have a title or not
- (void)updateTopAnchorConstraint {
    self.descriptionLabelTopConstraint.constant = self.hasTitle || !self.hasIcon ? BPKSpacingMd : 0;
    [self setNeedsLayout];
}

- (void)setupFlareViewConstraints {
    [NSLayoutConstraint activateConstraints:@[
        [self.flareView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [self.flareView.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor],
        [self.flareView.heightAnchor constraintGreaterThanOrEqualToConstant:150.0],
        [self.flareView.heightAnchor constraintLessThanOrEqualToConstant:300.0],
    ]];
}

- (BOOL)hasTitle {
    return (self.titleLabel.text != nil && ![self.titleLabel.text isEqualToString:@""]);
}

#pragma mark - Dynamic colors
- (UIColor *)dialogContentViewBackgroundColor {
    return [BPKColor dynamicColorWithLightVariant:BPKColor.white darkVariant:BPKColor.backgroundSecondaryDarkColor];
}

@end
NS_ASSUME_NONNULL_END
