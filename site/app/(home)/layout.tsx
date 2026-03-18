import { HomeLayout } from 'fumadocs-ui/layouts/home';
import { baseOptions } from '@/lib/layout.shared';

export default function Layout({ children }: LayoutProps<'/'>) {
  const options = baseOptions();

  return (
    <HomeLayout
      {...options}
      nav={{
        ...options.nav,
        enabled: false,
      }}
      className="bg-[#090909] text-white [--color-fd-background:#090909] [--color-fd-foreground:#fafafa] [--color-fd-card:#111111] [--color-fd-card-foreground:#fafafa] [--color-fd-muted:#121212] [--color-fd-muted-foreground:#a1a1aa] [--color-fd-border:rgba(255,255,255,0.08)] [--color-fd-accent:rgba(255,255,255,0.06)] [--color-fd-accent-foreground:#fafafa] [--color-fd-primary:#f97316] [--color-fd-primary-foreground:#ffffff]"
    >
      {children}
    </HomeLayout>
  );
}
