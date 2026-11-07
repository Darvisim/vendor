module microui_test;
import microui::mu;

mu::MuContext ctx;

fn int test_text_width(mu::MuFont font, char* str, int len) { return len * 8; }
fn int test_text_height(mu::MuFont font) { return 16; }

fn void setup()
{
    mu::init(&ctx);
    ctx.text_width = &test_text_width;
    ctx.text_height = &test_text_height;
}

fn void test_types() @test
{
    mu::MuVec2 v = mu::vec2(10, 20);
    assert(v.x == 10 && v.y == 20);

    mu::MuRect r = mu::rect(10, 20, 100, 50);
    assert(r.x == 10 && r.y == 20 && r.w == 100 && r.h == 50);

    mu::MuColor c = mu::color(255, 128, 64, 255);
    assert(c.r == 255 && c.g == 128 && c.b == 64 && c.a == 255);
}

fn void test_init() @test
{
    mu::init(&ctx);
    assert(ctx.frame == 0 && ctx.commandlist.idx == 0);
}

fn void test_input() @test
{
    mu::init(&ctx);

    int left = (int)mu::MuMouseButton.LEFT;
    int backspace = (int)mu::MuKey.BACKSPACE;

    mu::input_mousemove(&ctx, 100, 200);
    assert(ctx.mouse_pos.x == 100 && ctx.mouse_pos.y == 200);

    mu::input_mousedown(&ctx, 100, 200, left);
    assert((ctx.mouse_down & left) != 0);

    mu::input_mouseup(&ctx, 100, 200, left);
    assert((ctx.mouse_down & left) == 0);

    mu::input_scroll(&ctx, 10, -20);
    assert(ctx.scroll_delta.x == 10 && ctx.scroll_delta.y == -20);

    mu::input_keydown(&ctx, backspace);
    assert((ctx.key_down & backspace) != 0);
    assert((ctx.key_pressed & backspace) != 0);

    mu::input_keyup(&ctx, backspace);
    assert((ctx.key_down & backspace) == 0);

    mu::input_text(&ctx, "abc");
    assert(ctx.input_text_written == 3);
    assert(ctx.input_text[0] == 'a' && ctx.input_text[1] == 'b' && ctx.input_text[2] == 'c');
}

fn void test_frame_and_commands() @test
{
    setup();
    assert(ctx.frame == 0);

    mu::begin(&ctx);
    assert(ctx.frame == 1);

    if (mu::begin_window(&ctx, "Test", mu::rect(0, 0, 200, 150)))
    {
        mu::draw_rect(&ctx, mu::rect(10, 10, 100, 50), mu::color(255, 0, 0, 255));
        mu::end_window(&ctx);
    }

    assert(ctx.commandlist.idx > 0);
    mu::end(&ctx);

    mu::begin(&ctx);
    assert(ctx.frame == 2);
    mu::end(&ctx);
}

fn void test_ids() @test
{
    mu::init(&ctx);

    mu::MuId root = mu::get_id(&ctx, "item", 4);
    assert(root == mu::get_id(&ctx, "item", 4));
    assert(ctx.last_id == root);

    mu::push_id(&ctx, "parent", 6);
    assert(mu::get_id(&ctx, "item", 4) != root);
    mu::pop_id(&ctx);

    assert(mu::get_id(&ctx, "item", 4) == root);
}

fn void test_clipping() @test
{
    setup();
    mu::begin(&ctx);

    if (mu::begin_window(&ctx, "Test", mu::rect(0, 0, 200, 150)))
    {
        mu::MuRect clip = mu::get_clip_rect(&ctx);
        assert(clip.w > 0 && clip.h > 0);
        assert(mu::check_clip(&ctx, clip) == 0);
        assert(mu::check_clip(&ctx, mu::rect(clip.x + clip.w + 10, clip.y, 10, 10)) != 0);
        mu::end_window(&ctx);
    }

    mu::end(&ctx);
}

fn void test_pool() @test
{
    setup();

    mu::MuPoolItem[3] items;
    mu::begin(&ctx);

    mu::MuId id = mu::get_id(&ctx, "item", 4);
    int index = mu::pool_init(&ctx, &items[0], 3, id);

    assert(index >= 0 && index < 3);
    assert(mu::pool_get(&ctx, &items[0], 3, id) == index);

    mu::pool_update(&ctx, &items[0], index);
    mu::end(&ctx);
}

fn void test_layout() @test
{
    setup();
    mu::begin(&ctx);

    if (mu::begin_window(&ctx, "Layout Test", mu::rect(0, 0, 300, 200)))
    {
        int[2] widths = { 50, 70 };
        mu::layout_row(&ctx, 2, &widths[0], 20);

        mu::MuRect first = mu::layout_next(&ctx);
        mu::MuRect second = mu::layout_next(&ctx);

        assert(first.w == 50 && second.w == 70);
        assert(first.h == 20 && second.h == 20);
        assert(first.y == second.y);
        assert(second.x == first.x + first.w + ctx.style.spacing);

        mu::MuRect third = mu::layout_next(&ctx);
        assert(third.w == 50 && third.h == 20);
        assert(third.x == first.x);
        assert(third.y == first.y + first.h + ctx.style.spacing);

        mu::MuRect expected = mu::rect(10, 20, 80, 30);
        mu::layout_set_next(&ctx, expected, 0);

        mu::MuRect custom = mu::layout_next(&ctx);
        assert(custom.x == expected.x && custom.y == expected.y);
        assert(custom.w == expected.w && custom.h == expected.h);

        mu::layout_row(&ctx, 0, null, 0);
        mu::layout_width(&ctx, 60);
        mu::layout_height(&ctx, 25);

        mu::MuRect sized = mu::layout_next(&ctx);
        assert(sized.w == 60 && sized.h == 25);

        int[2] column_widths = { 100, 100 };
        mu::layout_row(&ctx, 2, &column_widths[0], 80);
        mu::layout_begin_column(&ctx);

        int column_width = 60;
        mu::layout_row(&ctx, 1, &column_width, 20);

        mu::MuRect item = mu::layout_next(&ctx);
        assert(item.w == 60 && item.h == 20);

        mu::layout_end_column(&ctx);

        mu::MuRect next = mu::layout_next(&ctx);
        assert(next.w == 100 && next.x > item.x);

        mu::end_window(&ctx);
    }

    mu::end(&ctx);
}
