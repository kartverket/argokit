{
  forHostnames(ingress): {
    spec+: {
      ingresses+: if std.type(ingress) == 'array' then ingress else [ingress],
    },
  },
}