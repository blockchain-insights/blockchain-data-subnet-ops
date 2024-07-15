-- init.sql

DO
$$
BEGIN
    -- Grant privileges on the public schema to the current user
    EXECUTE 'GRANT ALL PRIVILEGES ON SCHEMA public TO ' || current_user;
END
$$;
