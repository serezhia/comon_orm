import { RootProvider } from 'fumadocs-ui/provider/next';
import './global.css';
import { Manrope, Space_Grotesk } from 'next/font/google';
import type { Metadata } from 'next';

const manrope = Manrope({
  subsets: ['latin'],
  variable: '--font-body',
});

const spaceGrotesk = Space_Grotesk({
  subsets: ['latin'],
  variable: '--font-display',
});

const siteUrl = process.env.NEXT_PUBLIC_SITE_URL ?? 'https://comon.serezhia.ru';

export const metadata: Metadata = {
  metadataBase: new URL(siteUrl),
  title: {
    default: 'Comon ORM',
    template: '%s | Comon ORM',
  },
  description: 'Schema-first ORM documentation for Dart, PostgreSQL, SQLite, and Flutter SQLite.',
  alternates: {
    canonical: '/',
  },
  openGraph: {
    siteName: 'Comon ORM',
    url: siteUrl,
  },
};

export default function Layout({ children }: LayoutProps<'/'>) {
  return (
    <html
      lang="en"
      className={`${manrope.variable} ${spaceGrotesk.variable}`}
      suppressHydrationWarning
    >
      <body className="flex flex-col min-h-screen">
        <RootProvider>{children}</RootProvider>
      </body>
    </html>
  );
}
