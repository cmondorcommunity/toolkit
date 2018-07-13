resource "aws_cloudwatch_log_group" "main" {
  name = "${var.environment}-${var.project}-${var.org}"
}

resource "aws_cloudwatch_log_stream" "main" {
  log_group_name = "${aws_cloudwatch_log_group.main.name}"
  name           = "${var.org}-${var.project}-${var.environment}"
}
