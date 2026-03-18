import Link from 'next/link';

export default function HomePage() {
  return (
    <main className="relative flex flex-1 overflow-hidden bg-[#090909] px-6 py-10 text-white sm:px-10 lg:px-16 lg:py-16">
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_left,rgba(249,115,22,0.28),transparent_26%),radial-gradient(circle_at_80%_20%,rgba(251,191,36,0.16),transparent_18%),radial-gradient(circle_at_bottom_right,rgba(234,88,12,0.18),transparent_24%),linear-gradient(180deg,#101010_0%,#090909_58%,#060606_100%)]" />
      <div className="absolute inset-x-0 top-0 h-px bg-[linear-gradient(90deg,transparent,rgba(249,115,22,0.7),transparent)]" />
      <div className="absolute left-[8%] top-24 h-56 w-56 rounded-full bg-orange-500/10 blur-3xl" />
      <div className="absolute bottom-16 right-[10%] h-72 w-72 rounded-full bg-amber-300/8 blur-3xl" />

      <div className="relative mx-auto grid w-full max-w-6xl gap-10 lg:grid-cols-[1.08fr_0.92fr] lg:items-center">
        <section className="space-y-8 lg:space-y-10">
          <div className="inline-flex items-center rounded-full border border-orange-400/20 bg-white/6 px-4 py-2 text-xs font-semibold uppercase tracking-[0.2em] text-orange-300 shadow-[0_0_0_1px_rgba(255,255,255,0.02)] backdrop-blur">
            Schema-first ORM for Dart
          </div>

          <div className="space-y-5">
            <h1
              className="max-w-4xl text-5xl font-semibold tracking-[-0.07em] text-balance text-white sm:text-6xl xl:text-7xl"
              style={{ fontFamily: 'var(--font-display), sans-serif' }}
            >
              Dark, fast, typed access to your database from one schema.
            </h1>
            <p className="max-w-2xl text-lg leading-8 text-zinc-300 sm:text-xl">
              Model once in schema.prisma, generate a Dart client, review the migration path, and ship the same developer experience across PostgreSQL, SQLite, and Flutter SQLite.
            </p>
          </div>

          <div className="flex flex-wrap gap-3">
            <Link
              href="/docs/core"
              className="inline-flex items-center rounded-2xl bg-orange-500 px-5 py-3 text-sm font-semibold text-white shadow-[0_18px_40px_rgba(249,115,22,0.28)] transition hover:translate-y-[-1px] hover:bg-orange-400"
            >
              Open documentation
            </Link>
            <Link
              href="https://github.com/serezhia/comon_orm"
              className="inline-flex items-center rounded-2xl border border-white/12 bg-white/6 px-5 py-3 text-sm font-semibold text-zinc-100 transition hover:bg-white/10"
            >
              View repository
            </Link>
          </div>

          <div className="grid gap-4 sm:grid-cols-3">
            <div className="rounded-3xl border border-white/8 bg-white/5 p-5 shadow-[0_20px_50px_rgba(0,0,0,0.22)] backdrop-blur-sm">
              <p className="text-sm font-semibold text-orange-300">Schema</p>
              <p className="mt-2 text-sm leading-6 text-zinc-400">
                Prisma-style models, relations, enums, mappings, and provider-aware native types.
              </p>
            </div>
            <div className="rounded-3xl border border-white/8 bg-white/5 p-5 shadow-[0_20px_50px_rgba(0,0,0,0.22)] backdrop-blur-sm">
              <p className="text-sm font-semibold text-orange-300">Dart</p>
              <p className="mt-2 text-sm leading-6 text-zinc-400">
                Generated delegates, nested writes, filters, aggregation, and metadata-driven runtime openers.
              </p>
            </div>
            <div className="rounded-3xl border border-white/8 bg-white/5 p-5 shadow-[0_20px_50px_rgba(0,0,0,0.22)] backdrop-blur-sm">
              <p className="text-sm font-semibold text-orange-300">Migrations</p>
              <p className="mt-2 text-sm leading-6 text-zinc-400">
                Reviewed shared-database rollout and explicit local upgrade paths for Flutter SQLite.
              </p>
            </div>
          </div>
        </section>

        <section className="relative lg:pl-6">
          <div className="absolute -inset-4 rounded-[2.25rem] bg-[radial-gradient(circle_at_top,rgba(249,115,22,0.18),transparent_46%)] blur-2xl" />
          <div className="relative overflow-hidden rounded-[2rem] border border-orange-400/18 bg-[#111111] shadow-[0_32px_90px_rgba(0,0,0,0.48)]">
            <div className="flex items-center justify-between border-b border-white/8 px-5 py-4 text-[11px] uppercase tracking-[0.2em] text-zinc-400">
              <span className="text-orange-300">Quick Start</span>
              <span>schema to runtime</span>
            </div>

            <div className="space-y-5 p-5">
              <div className="rounded-2xl border border-white/6 bg-black/25 p-4">
                <div className="mb-3 flex items-center gap-2 text-[11px] font-semibold uppercase tracking-[0.18em] text-zinc-500">
                  <span className="h-2 w-2 rounded-full bg-orange-400" />
                  schema.prisma
                </div>
                <pre className="overflow-x-auto whitespace-pre-wrap text-sm leading-7 text-zinc-200">
                  <code>{`datasource db {
  provider = "sqlite"
  url      = "dev.db"
}

generator client {
  provider = "comon_orm"
  output   = "lib/generated/comon_orm_client.dart"
}

model User {
  id    Int    @id @default(autoincrement())
  email String @unique
  name  String?
}`}</code>
                </pre>
              </div>

              <div className="grid gap-3 sm:grid-cols-2">
                <div className="rounded-2xl border border-white/6 bg-white/4 p-4">
                  <p className="text-[11px] font-semibold uppercase tracking-[0.18em] text-zinc-500">
                    Generate
                  </p>
                  <pre className="mt-3 overflow-x-auto text-sm leading-6 text-zinc-200">
                    <code>dart run comon_orm generate schema.prisma</code>
                  </pre>
                </div>
                <div className="rounded-2xl border border-white/6 bg-white/4 p-4">
                  <p className="text-[11px] font-semibold uppercase tracking-[0.18em] text-zinc-500">
                    Apply
                  </p>
                  <pre className="mt-3 overflow-x-auto text-sm leading-6 text-zinc-200">
                    <code>dart run comon_orm migrate apply --schema schema.prisma --name init</code>
                  </pre>
                </div>
              </div>

              <div className="rounded-2xl border border-orange-400/15 bg-orange-500/8 p-4 text-sm leading-7 text-zinc-200">
                Then open <span className="font-semibold text-white">GeneratedComonOrmClientSqlite</span> and work through typed delegates instead of handwritten SQL wrappers.
              </div>
            </div>
          </div>
        </section>
      </div>
    </main>
  );
}
