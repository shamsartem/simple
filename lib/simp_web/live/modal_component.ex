defmodule SimpWeb.ModalComponent do
  use SimpWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <div
      id="<%= @id %>"
      class="modal"
      phx-capture-click="close"
      phx-window-keydown="close"
      phx-key="escape"
      phx-target="#<%= @id %>"
      phx-page-loading
      phx-hook="FocusTrap"
    >
      <div class="modal__content">
        <%= live_patch raw("&times;"), to: @return_to, class: "modal__close" %>
        <%= live_component @socket, @component, @opts %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
