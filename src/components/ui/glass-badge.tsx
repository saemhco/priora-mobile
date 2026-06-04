import { StyleSheet, View, Platform } from 'react-native';
import { GlassView } from 'expo-glass-effect';
import { SymbolView } from 'expo-symbols';
import { ThemedText } from '@/components/themed-text';
import { useTheme } from '@/hooks/use-theme';
import { Spacing } from '@/constants/theme';

export function GlassBadge() {
  const theme = useTheme();

  return (
    <GlassView
      glassEffectStyle="regular"
      style={[
        styles.glassContainer,
        {
          borderColor: theme.cardBorder,
          // Fallback background for non-iOS platforms
          backgroundColor: Platform.select({
            ios: 'transparent',
            default: theme.background === '#0B0F19' ? 'rgba(22, 31, 48, 0.8)' : 'rgba(255, 255, 255, 0.8)',
          }),
        },
      ]}
    >
      <View style={[styles.iconContainer, { backgroundColor: theme.tealBackground }]}>
        <SymbolView
          name={{
            ios: 'heart.fill',
            android: 'favorite',
            web: 'favorite',
          }}
          size={18}
          tintColor={theme.teal}
        />
      </View>
      <View style={styles.textContainer}>
        <ThemedText style={styles.topText} themeColor="textSecondary">
          Tu Salud Primero
        </ThemedText>
        <ThemedText style={styles.bottomText} themeColor="primary">
          Conectada
        </ThemedText>
      </View>
    </GlassView>
  );
}

const styles = StyleSheet.create({
  glassContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 20,
    borderWidth: StyleSheet.hairlineWidth,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.08,
    shadowRadius: 12,
    elevation: 3,
    gap: Spacing.two,
  },
  iconContainer: {
    width: 36,
    height: 36,
    borderRadius: 18,
    alignItems: 'center',
    justifyContent: 'center',
  },
  textContainer: {
    flexDirection: 'column',
  },
  topText: {
    fontSize: 11,
    fontWeight: '600',
    letterSpacing: 0.3,
  },
  bottomText: {
    fontSize: 15,
    fontWeight: '800',
  },
});
