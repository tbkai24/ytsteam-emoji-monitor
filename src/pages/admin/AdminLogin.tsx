import { type FormEvent, useEffect, useState } from 'react'
import { Navigate, useNavigate } from 'react-router-dom'
import Button from '../../components/ui/Button'
import Card from '../../components/ui/Card'
import Input from '../../components/ui/Input'
import { useAuth } from '../../lib/auth'
import { isSupabaseConfigured, supabase } from '../../lib/supabase'

const INVALID_LOGIN_MESSAGES = new Set([
  'Invalid login credentials',
  'Email not confirmed',
])

function AdminLogin() {
  const navigate = useNavigate()
  const { session, loading } = useAuth()

  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (session) {
      navigate('/admin/milestones', { replace: true })
    }
  }, [navigate, session])

  const handleSubmit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    setError(null)

    if (!isSupabaseConfigured) {
      setError(
        'Login is not available right now. Check the project configuration and try again.',
      )
      return
    }

    setSubmitting(true)

    try {
      const { error: signInError } = await supabase.auth.signInWithPassword({
        email,
        password,
      })

      if (signInError) {
        setError(
          INVALID_LOGIN_MESSAGES.has(signInError.message)
            ? 'Incorrect email or password.'
            : 'Login failed. Please try again.',
        )
        setSubmitting(false)
        return
      }
    } catch {
      setError('Unable to sign in right now. Please check your connection and try again.')
      setSubmitting(false)
      return
    }

    setSubmitting(false)
    navigate('/admin/milestones', { replace: true })
  }

  if (loading) {
    return (
      <div className="screen-center">
        <div className="spinner" />
      </div>
    )
  }

  if (session) {
    return <Navigate to="/admin/milestones" replace />
  }

  return (
    <div className="screen-center">
      <Card className="auth-card">
        <h1>Admin Login</h1>
        <p className="muted">Sign in with your admin account.</p>
        {error ? <p className="alert alert-error">{error}</p> : null}
        <form onSubmit={handleSubmit} className="stack-sm">
          <label className="stack-xs">
            <span>Email</span>
            <Input
              type="email"
              value={email}
              onChange={(event) => setEmail(event.target.value)}
              required
              autoComplete="email"
            />
          </label>
          <label className="stack-xs">
            <span>Password</span>
            <Input
              type="password"
              value={password}
              onChange={(event) => setPassword(event.target.value)}
              required
              autoComplete="current-password"
            />
          </label>
          <Button type="submit" disabled={submitting}>
            {submitting ? 'Signing In...' : 'Sign In'}
          </Button>
        </form>
      </Card>
    </div>
  )
}

export default AdminLogin
