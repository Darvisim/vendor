module microui_test;
import microui::mu;

extern fn usz strlen(char *s) @cname("strlen");

fn void test_window(MuContext* ctx)
{
  if (mu::begin_window(ctx, "Test Window", mu::rect(40, 40, 300, 450)))
  {
    MuContainer *win = mu::get_current_container(ctx);
    assert(win != null);
  
    win.rect.w = mu::max(win.rect.w, 240);
    win.rect.h = mu::max(win.rect.h, 300);
    assert(win.rect.w >= 240);
    assert(win.rect.h >= 300);

    mu::text(ctx, "Lorem ipsum dolor sit amet, consectetur adipiscing" 
                "elit. Maecenas lacinia, sem eu lacinia molestie, mi risus faucibus" 
                "ipsum, eu varius magna felis a nulla.");
  
    mu::button(ctx, "Test Button");
    mu::label(ctx, "Test Label");

    static int[3] checks = { 1, 0, 1 };
    mu::checkbox(ctx, "Checkbox 1", &checks[0]);
    mu::checkbox(ctx, "Checkbox 2", &checks[1]);
    mu::checkbox(ctx, "Checkbox 3", &checks[2]);

    assert(checks[0] == 0 || checks[0] == 1);
    assert(checks[1] == 0 || checks[1] == 1);
    assert(checks[2] == 0 || checks[2] == 1);

    static int[3] bg = { 128, 128, 128 };
    static int idx = 0;

    mu::label(ctx, "Red:");
    mu::slider(ctx, &bg[0], &idx, 0, 255);

    mu::label(ctx, "Green:");
    mu::slider(ctx, &bg[1], &idx, 0, 255);

    mu::label(ctx, "Blue:");
    mu::slider(ctx, &bg[2], &idx, 0, 255);

    assert(bg[0] >= 0 && bg[0] <= 255);
    assert(bg[1] >= 0 && bg[1] <= 255);
    assert(bg[2] >= 0 && bg[2] <= 255);

    if (mu::button(ctx, "Popup"))
    {
      mu::open_popup(ctx, "Test Popup");
    }
    
    if (mu::begin_popup(ctx, "Test Popup"))
    {
      mu::button(ctx, "Hello");
      mu::button(ctx, "World");
      mu::end_popup(ctx);
    }

    if (mu::begin_treenode(ctx, "Test 1"))
    {
      if (mu::begin_treenode(ctx, "Test 1a"))
      {
          mu::label(ctx, "Hello");
          mu::label(ctx, "world");
          mu::end_treenode(ctx);
      }
      mu::end_treenode(ctx);
    }
    
    mu::end_window(ctx);
  }
}

fn int test_text_width(MuFont font, char* str, int len)
{
  assert(str != null || len == 0);
  if (len < 0) len = (int)strlen(str);
  return len * 8;
}

fn int test_text_height(MuFont font)
{
  return 16;
}

fn void test_draw_frame(MuContext* ctx, MuRect rect, int colorid)
{
  assert(rect.w >= 0 && rect.h >= 0);
  assert(colorid >= 0 && colorid < (int)MuColorId.MAX);
}

fn void test_main() @test
{
  MuContext* ctx = malloc(MuContext::size);
  assert(ctx != null);

  mu::init(ctx);

  ctx.text_width = (TextWidth)&test_text_width;
  ctx.text_height = (TextHeight)&test_text_height;
  ctx.draw_frame = (DrawFrame)&test_draw_frame;

  assert(ctx.text_width != null);
  assert(ctx.text_height != null);
  assert(ctx.draw_frame != null);

  mu::begin(ctx);
  test_window(ctx);
  mu::end(ctx);

  MuCommand* cmd = null;

  while (mu::next_command(ctx, &cmd))
  {
    assert(cmd != null);

    switch (cmd.base.type)
    {
        case (int)MuCommandType.CLIP:
            assert(cmd.clip.rect.x >= 0 && cmd.clip.rect.y >= 0
              && cmd.clip.rect.w >= 0 && cmd.clip.rect.h >= 0);

        case (int)MuCommandType.RECT:
            assert(cmd.rect.rect.x >= 0 && cmd.rect.rect.y >= 0
              && cmd.rect.rect.w >= 0 && cmd.rect.rect.h >= 0);

        case (int)MuCommandType.TEXT:
            assert(cmd.text.pos.x >= 0 && cmd.text.pos.y >= 0);
            assert(cmd.text.color.r <= 255 && cmd.text.color.g <= 255
              && cmd.text.color.b <= 255 && cmd.text.color.a <= 255);

        case (int)MuCommandType.ICON:
            assert(cmd.icon.rect.x >= 0 && cmd.icon.rect.y >= 0
              && cmd.icon.rect.w >= 0 && cmd.icon.rect.h >= 0);
            assert(cmd.icon.id >= 0 && cmd.icon.id < (int)MuIcon.MAX);

        default:
            break;
    }
  }
  
  free(ctx);
}
