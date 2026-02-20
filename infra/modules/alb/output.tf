output "web_tg_arn" {
  value = aws_lb_target_group.web_tg.arn
}

output "alb_zone_id" {
  value = aws_lb.alb.zone_id
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}