
resource "aws_lb" "public_load_balancer" {
  name               = "${local.deployment_name}--nlb"
  load_balancer_type = "application"
  enable_cross_zone_load_balancing = true
  internal = false
  subnets = aws_subnet.tally-subnet-public[*].id
  security_groups = [aws_security_group.security_group.id]
  idle_timeout = 5

  //  subnet_mapping {
  //  subnet_id     = lookup(var.nlb_config,"subnet")
  //  allocation_id = aws_eip.eip_nlb.id
  //}

  tags = merge(
    local.common_tags, {"Name" = "${local.deployment_name}-nlb"}

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
    local.common_tags, {"Name" = "${local.deployment_name}-nlb--listener"}

     )
}



resource "aws_lb_target_group" "tg" {
  for_each = var.forwarding_config
    name                  = "${local.deployment_name}-${each.key}--tg"
    port                  = each.key
    protocol              = each.value
    vpc_id                = aws_vpc.tally-vpc.id
    target_type           = "instance"
    deregistration_delay    = 90

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
    local.common_tags, {"Name" = "${local.deployment_name}--nlb-tg"}

     )
}

resource "aws_alb_target_group_attachment" "target_group" {
  for_each = {
    for pair in setproduct(keys(var.forwarding_config ),range(length(aws_instance.web_server))) : "${pair[0]} ${pair[1]}" => {
      target_group_arn = pair[0]
      target_id        = pair[1]
    }
  }
  target_group_arn = aws_lb_target_group.tg[each.value.target_group_arn].arn
  target_id        = aws_instance.web_server[each.value.target_id].id
}