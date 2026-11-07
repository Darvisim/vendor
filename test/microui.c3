module microui_test;
import microui::mu;

mu::MuContext ctx;

fn void test_vector() @test
{
	mu::MuVec2 v = mu::vec2(10, 20);
	assert(v.x == 10);
	assert(v.y == 20);
}

fn void test_rectangle() @test
{
	mu::MuRect r = mu::rect(10, 20, 100, 50);
	assert(r.x == 10);
	assert(r.y == 20);
	assert(r.w == 100);
	assert(r.h == 50);
}

fn void test_color() @test
{
	mu::MuColor c = mu::color(255, 128, 64, 255);
	assert(c.r == 255);
	assert(c.g == 128);
	assert(c.b == 64);
	assert(c.a == 255);
}

fn void test_init() @test
{
	mu::init(&ctx);
	assert(ctx.frame == 0);
	assert(ctx.commandlist.idx == 0);
}

fn void test_mouse_input() @test
{
	mu::input_mousemove(&ctx, 100, 200);
	assert(ctx.mouse_pos.x == 100);
	assert(ctx.mouse_pos.y == 200);

	mu::input_mousedown(&ctx, 100, 200, (int)mu::MuMouseButton.LEFT);
	assert((ctx.mouse_down & (int)mu::MuMouseButton.LEFT) != 0);

	mu::input_mouseup(&ctx, 100, 200, (int)mu::MuMouseButton.LEFT);
	assert((ctx.mouse_down & (int)mu::MuMouseButton.LEFT) == 0);
}

fn void test_command()
{
	mu::begin(&ctx);
	mu::draw_rect(
		&ctx,
		mu::rect(10, 10, 100, 50),
		mu::color(255, 0, 0, 255)
	);
	assert(ctx.commandlist.idx > 0);
	mu::end(&ctx);
}
