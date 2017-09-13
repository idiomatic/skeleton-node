const Koa = require('koa')
const app = new Koa()
const router = require('koa-router')()

const { PORT = 3000 } = process.env

router.get('/hello', async (ctx, next) => {
    ctx.body = { greeting: 'hello world\n' }
})

app.use(require('koa-static')(__dirname + '/static'))
app.use(router.routes())

app.listen(PORT)
