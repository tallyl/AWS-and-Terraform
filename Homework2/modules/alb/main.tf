
resource "aws_lb" "public_load_balancer" {
  name               = "${var.deployment_name}--nlb"
  load_balancer_type = "application"
  enable_cross_zone_load_balancing = true
  internal = false
  subnets = var.public_subnets[*].id
  security_groups = [var.sg_id]
  idle_timeout = 60

  //  subnet_mapping {
  //  subnet_id     = lookup(var.nlb_config,"subnet")
  //  allocation_id = aws_eip.eip_nlb.id
  //}

  tags = merge(
    var.common_tags, {"Name" = "${var.deployment_name}-nlb"}

     )
}


resource "aws_lb_listener" "lb_listener" {
  //count             = length(var.nlb_ports)
  for_each = var.forwarding_config
  load_balancer_arn = aws_lb.public_load_balancer.arn
  port              = each.key
  protocol          = each.value

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[each.key].arn
  }

  tags = merge(
    var.common_tags, {"Name" = "${var.deployment_name}-nlb--listener"}

     )
}



resource "aws_lb_target_group" "tg" {
  for_each = var.forwarding_config
    name                  = "${var.deployment_name}-${each.key}--tg"
    port                  = each.key
    protocol              = each.value
    vpc_id                = var.vpc_id
    target_type           = "instance"
    deregistration_delay    = 90
    stickiness {
      type = "lb_cookie"
      cookie_duration = 60
  }

  health_check {
    enabled = true
    path    = "/"
  }
/*health_check {
    interval            = 30
    port                = "traffic-port" //each.value != "TCP_UDP" ? each.key : 80
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }*/
  tags = merge(
    var.common_tags, {"Name" = "${var.deployment_name}--nlb-tg"}

     )
}

resource "aws_alb_target_group_attachment" "target_group" {
  for_each = {
    for pair in setproduct(keys(var.forwarding_config ),range(length(var.web_servers))) : "${pair[0]} ${pair[1]}" => {
      target_group_arn = pair[0]
      target_id        = pair[1]
    }
  }
  target_group_arn = aws_lb_target_group.tg[each.value.target_group_arn].arn
  target_id        = var.web_servers[each.value.target_id].id
}
