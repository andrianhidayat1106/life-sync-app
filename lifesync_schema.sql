-- ===========================================================================
-- DATABASE SCHEMA & ERD FOR LIFESYNC APP
-- Target Database: PostgreSQL (Supabase Compatible)
-- Created: 2026-05-26
-- Author: Antigravity AI
-- Description: This SQL schema represents the Entity Relationship Diagram (ERD)
--              for the LifeSync app. It includes tables for User Profiles,
--              Categories, Wallets, Transactions, Projects, Tasks, and Notifications.
-- ===========================================================================

-- Enable UUID extension if not enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ===========================================================================
-- 1. TABLE: profiles
-- Description: Stores user profile information linked to Supabase Auth.
-- ===========================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE public.profiles IS 'Stores details of user accounts, linked to auth.users.';

-- ===========================================================================
-- 2. TABLE: categories
-- Description: Stores categories for transactions, tasks, or projects.
--              Includes visual attributes like icons and color hex codes.
-- ===========================================================================
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL CHECK (type IN ('finance', 'task', 'project', 'general')),
    icon VARCHAR(100) NOT NULL, -- e.g., 'shopping_cart', 'work', etc.
    color_hex VARCHAR(9) NOT NULL, -- Hex code, e.g., '#FF065F46'
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_user_category UNIQUE (user_id, name, type)
);

COMMENT ON TABLE public.categories IS 'User-defined or system categories for finance or productivity tasks.';

-- ===========================================================================
-- 3. TABLE: wallets
-- Description: Stores user wallet sources (e.g., Bank accounts, e-wallets).
-- ===========================================================================
CREATE TABLE IF NOT EXISTS public.wallets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    balance NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    color_hex VARCHAR(9) NOT NULL, -- e.g., '#FF1E293B'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE public.wallets IS 'User financial account nodes that hold balances and trace transactions.';

-- ===========================================================================
-- 4. TABLE: transactions
-- Description: Stores transaction logs (incomes and expenses/outcomes)
--              referencing specific wallets and categories.
-- ===========================================================================
CREATE TABLE IF NOT EXISTS public.transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    wallet_id UUID NOT NULL REFERENCES public.wallets(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES public.categories(id) ON DELETE RESTRICT,
    amount NUMERIC(15, 2) NOT NULL CHECK (amount >= 0),
    type VARCHAR(20) NOT NULL CHECK (type IN ('income', 'outcome')), -- 'income' (Pemasukan), 'outcome' (Pengeluaran)
    transaction_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE public.transactions IS 'Logs transactions, adjusting associated wallet balances.';

-- ===========================================================================
-- 5. TABLE: projects
-- Description: Stores structured user projects that group related tasks.
-- ===========================================================================
CREATE TABLE IF NOT EXISTS public.projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    priority VARCHAR(20) NOT NULL DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
    deadline TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE public.projects IS 'Groups high-level objectives consisting of multiple sub-tasks.';

-- ===========================================================================
-- 6. TABLE: tasks
-- Description: Stores daily checklist tasks. Can be standalone or belong 
--              to a project.
-- ===========================================================================
CREATE TABLE IF NOT EXISTS public.tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    project_id UUID REFERENCES public.projects(id) ON DELETE CASCADE,
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    priority VARCHAR(20) NOT NULL DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
    due_date TIMESTAMP WITH TIME ZONE,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    task_time TIME, -- e.g., '16:30:00'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE public.tasks IS 'Checklist tasks to keep users productive, linked optionally to projects/categories.';

-- ===========================================================================
-- 7. TABLE: notifications
-- Description: Logs alerts and system notifications for the user.
-- ===========================================================================
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    type VARCHAR(50) DEFAULT 'general', -- e.g., 'payment', 'task_deadline', 'security'
    icon VARCHAR(100), -- e.g., 'check_circle_outline'
    is_unread BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE public.notifications IS 'Notifications delivered to users regarding transactions, tasks, or security alerts.';

-- ===========================================================================
-- TRIGGERS & FUNCTIONS: Auto Update `updated_at` timestamps
-- ===========================================================================

-- Trigger function to update the updated_at column
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers
CREATE TRIGGER set_profiles_updated_at
BEFORE UPDATE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_categories_updated_at
BEFORE UPDATE ON public.categories
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_wallets_updated_at
BEFORE UPDATE ON public.wallets
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_transactions_updated_at
BEFORE UPDATE ON public.transactions
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_projects_updated_at
BEFORE UPDATE ON public.projects
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_tasks_updated_at
BEFORE UPDATE ON public.tasks
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();


-- ===========================================================================
-- INDEXES: Optimizing read operations (indexes on Foreign Keys and search terms)
-- ===========================================================================
CREATE INDEX IF NOT EXISTS idx_categories_user ON public.categories(user_id);
CREATE INDEX IF NOT EXISTS idx_wallets_user ON public.wallets(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_user ON public.transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_wallet ON public.transactions(wallet_id);
CREATE INDEX IF NOT EXISTS idx_transactions_category ON public.transactions(category_id);
CREATE INDEX IF NOT EXISTS idx_projects_user ON public.projects(user_id);
CREATE INDEX IF NOT EXISTS idx_tasks_user ON public.tasks(user_id);
CREATE INDEX IF NOT EXISTS idx_tasks_project ON public.tasks(project_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications(user_id, is_unread);

-- ===========================================================================
-- TRIGGERS FOR WALLET BALANCE ADJUSTMENT
-- Description: Automatically adds to or subtracts from wallet balances
--              whenever transactions are recorded, modified, or deleted.
-- ===========================================================================

CREATE OR REPLACE FUNCTION public.adjust_wallet_balance()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF (NEW.type = 'income') THEN
            UPDATE public.wallets 
            SET balance = balance + NEW.amount 
            WHERE id = NEW.wallet_id;
        ELSIF (NEW.type = 'outcome') THEN
            UPDATE public.wallets 
            SET balance = balance - NEW.amount 
            WHERE id = NEW.wallet_id;
        END IF;
        
    ELSIF (TG_OP = 'UPDATE') THEN
        -- Revert old transaction amounts
        IF (OLD.type = 'income') THEN
            UPDATE public.wallets 
            SET balance = balance - OLD.amount 
            WHERE id = OLD.wallet_id;
        ELSIF (OLD.type = 'outcome') THEN
            UPDATE public.wallets 
            SET balance = balance + OLD.amount 
            WHERE id = OLD.wallet_id;
        END IF;
        
        -- Apply new transaction amounts
        IF (NEW.type = 'income') THEN
            UPDATE public.wallets 
            SET balance = balance + NEW.amount 
            WHERE id = NEW.wallet_id;
        ELSIF (NEW.type = 'outcome') THEN
            UPDATE public.wallets 
            SET balance = balance - NEW.amount 
            WHERE id = NEW.wallet_id;
        END IF;
        
    ELSIF (TG_OP = 'DELETE') THEN
        -- Revert deleted transaction amounts
        IF (OLD.type = 'income') THEN
            UPDATE public.wallets 
            SET balance = balance - OLD.amount 
            WHERE id = OLD.wallet_id;
        ELSIF (OLD.type = 'outcome') THEN
            UPDATE public.wallets 
            SET balance = balance + OLD.amount 
            WHERE id = OLD.wallet_id;
        END IF;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_adjust_wallet_balance
AFTER INSERT OR UPDATE OR DELETE ON public.transactions
FOR EACH ROW EXECUTE FUNCTION public.adjust_wallet_balance();
