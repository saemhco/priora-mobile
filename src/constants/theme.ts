/**
 * Below are the colors that are used in the app. The colors are defined in the light and dark mode.
 * There are many other ways to style your app. For example, [Nativewind](https://www.nativewind.dev/), [Tamagui](https://tamagui.dev/), [unistyles](https://reactnativeunistyles.vercel.app), etc.
 */

import '@/global.css';

import { Platform } from 'react-native';

export const Colors = {
  light: {
    text: '#091E42',
    background: '#F4F7FC',
    backgroundElement: '#FFFFFF',
    backgroundSelected: '#E0E8F6',
    textSecondary: '#5E6C84',
    primary: '#1552C6',
    primaryPressed: '#0F3FA0',
    teal: '#0A7E74',
    tealBackground: '#DFF6F5',
    cardBorder: '#E2E8F0',
  },
  dark: {
    text: '#FFFFFF',
    background: '#0B0F19',
    backgroundElement: '#161F30',
    backgroundSelected: '#1E2C45',
    textSecondary: '#8996B2',
    primary: '#2B6FF5',
    primaryPressed: '#1A53D4',
    teal: '#14B8A6',
    tealBackground: '#132A29',
    cardBorder: '#1E293B',
  },
} as const;

export type ThemeColor = keyof typeof Colors.light & keyof typeof Colors.dark;

export const Fonts = Platform.select({
  ios: {
    /** iOS `UIFontDescriptorSystemDesignDefault` */
    sans: 'system-ui',
    /** iOS `UIFontDescriptorSystemDesignSerif` */
    serif: 'ui-serif',
    /** iOS `UIFontDescriptorSystemDesignRounded` */
    rounded: 'ui-rounded',
    /** iOS `UIFontDescriptorSystemDesignMonospaced` */
    mono: 'ui-monospace',
  },
  default: {
    sans: 'normal',
    serif: 'serif',
    rounded: 'normal',
    mono: 'monospace',
  },
  web: {
    sans: 'var(--font-display)',
    serif: 'var(--font-serif)',
    rounded: 'var(--font-rounded)',
    mono: 'var(--font-mono)',
  },
});

export const Spacing = {
  half: 2,
  one: 4,
  two: 8,
  three: 16,
  four: 24,
  five: 32,
  six: 64,
} as const;

export const BottomTabInset = Platform.select({ ios: 50, android: 80 }) ?? 0;
export const MaxContentWidth = 800;
