import { Image } from 'expo-image';
import { ScrollView, StyleSheet, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { ThemedText } from '@/components/themed-text';
import { ThemedView } from '@/components/themed-view';
import { Button } from '@/components/ui/button';
import { GlassBadge } from '@/components/ui/glass-badge';
import { Spacing } from '@/constants/theme';
import { useTheme } from '@/hooks/use-theme';

export default function OnboardingScreen() {
  const theme = useTheme();

  return (
    <ThemedView style={styles.container}>
      <SafeAreaView style={styles.safeArea}>
        <ScrollView
          contentContainerStyle={styles.scrollContent}
          showsVerticalScrollIndicator={false}
        >
          {/* Header Branding */}
          <View style={styles.header}>
            <View style={[styles.appLogo, { backgroundColor: theme.primary }]} />
            <ThemedText style={styles.appName} themeColor="primary">
              Priora
            </ThemedText>
            <ThemedText style={styles.tagline} themeColor="textSecondary">
              Orienta · Prioriza · Conecta
            </ThemedText>
          </View>

          {/* Hero Image Section */}
          <View style={styles.imageWrapper}>
            <Image
              source={require('@/assets/images/onboarding-doctor.png')}
              style={styles.heroImage}
              contentFit="cover"
              transition={200}
            />
            {/* Floating Glassmorphism Badge */}
            <View style={styles.badgeContainer}>
              <GlassBadge />
            </View>
          </View>

          {/* Actions Container */}
          <View style={styles.actions}>
            <Button
              title="Iniciar sesión"
              variant="solid"
              showArrow={true}
              onPress={() => console.log('Iniciar sesión tapped')}
            />
            <Button
              title="Crear cuenta"
              variant="outline"
              onPress={() => console.log('Crear cuenta tapped')}
            />
          </View>
        </ScrollView>
      </SafeAreaView>
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  safeArea: {
    flex: 1,
  },
  scrollContent: {
    flexGrow: 1,
    paddingHorizontal: Spacing.four,
    paddingTop: Spacing.four,
    paddingBottom: Spacing.five,
    justifyContent: 'space-between',
    alignItems: 'center',
    gap: Spacing.four,
  },
  header: {
    alignItems: 'center',
    gap: Spacing.two,
    width: '100%',
  },
  appLogo: {
    width: 64,
    height: 64,
    borderRadius: 18,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.15,
    shadowRadius: 8,
    elevation: 4,
  },
  appName: {
    fontSize: 28,
    fontWeight: '800',
    marginTop: Spacing.one,
  },
  tagline: {
    fontSize: 14,
    fontWeight: '600',
    letterSpacing: 0.5,
  },
  imageWrapper: {
    width: '100%',
    maxWidth: 360,
    aspectRatio: 1,
    position: 'relative',
    marginVertical: Spacing.three,
  },
  heroImage: {
    width: '100%',
    height: '100%',
    borderRadius: 36,
  },
  badgeContainer: {
    position: 'absolute',
    bottom: 20,
    right: -12,
  },
  actions: {
    width: '100%',
    maxWidth: 360,
    gap: Spacing.three,
    marginTop: Spacing.two,
  },
});
