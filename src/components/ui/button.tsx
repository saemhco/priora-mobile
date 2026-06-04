import { Pressable, StyleSheet, Text, type PressableProps } from 'react-native';
import { SymbolView } from 'expo-symbols';
import { useTheme } from '@/hooks/use-theme';
import { Fonts, Spacing } from '@/constants/theme';

export type ButtonVariant = 'solid' | 'outline';

export interface ButtonProps extends PressableProps {
  title: string;
  variant?: ButtonVariant;
  showArrow?: boolean;
}

export function Button({ title, variant = 'solid', showArrow = false, style, ...rest }: ButtonProps) {
  const theme = useTheme();

  const isSolid = variant === 'solid';

  const buttonStyle = [
    styles.button,
    isSolid
      ? { backgroundColor: theme.primary }
      : { borderColor: theme.teal, borderWidth: 1, backgroundColor: 'transparent' },
  ];

  const textStyle = [
    styles.text,
    isSolid ? { color: '#FFFFFF' } : { color: theme.teal },
  ];

  return (
    <Pressable
      style={(state) => [
        buttonStyle,
        state.pressed && (isSolid ? { backgroundColor: theme.primaryPressed } : { opacity: 0.7 }),
        typeof style === 'function' ? style(state) : style,
      ]}
      {...rest}
    >
      <Text style={textStyle}>{title}</Text>
      {showArrow && (
        <SymbolView
          name={{
            ios: 'arrow.right',
            android: 'arrow_right',
            web: 'arrow_right',
          }}
          size={18}
          tintColor={isSolid ? '#FFFFFF' : theme.teal}
          style={styles.arrow}
        />
      )}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  button: {
    height: 56,
    borderRadius: 14,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: Spacing.four,
    width: '100%',
    position: 'relative',
  },
  text: {
    fontSize: 16,
    fontWeight: '600',
    fontFamily: Fonts.sans,
    textAlign: 'center',
  },
  arrow: {
    position: 'absolute',
    right: Spacing.four,
  },
});
