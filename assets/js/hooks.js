import focusTrap from "focus-trap"

const hooks = {
  Autocomplete: {
    mounted() {
      this.el.addEventListener('input', (e) => {
        if (Array.from(e.target.list.options).map(o => o.value).includes(e.target.value)) {
          const allInputs = document.querySelectorAll('#transaction-form input')
          setTimeout(() => {
            const nextInput = allInputs[Array.from(allInputs).findIndex((el) => el === e.target) + 1]
            if (nextInput) {
              nextInput.focus()
            } else {
              document.querySelector('#transaction-form button[type="submit"]').focus()
            }
          });
        }
      })
    }
  },
  FocusTrap: {
    mounted() {
      this.focusTrap = focusTrap(this.el)
      this.focusTrap.activate()
    },
    beforeDestroy() {
      this.focusTrap.deactivate()
    }
  },
  SwipeNavigation: {
    mounted() {
      this.el.addEventListener('swiped-right', () => {
        this.pushEvent('swiped-right')
      })
      this.el.addEventListener('swiped-left', () => {
        this.pushEvent('swiped-left')
      })
    }
  }
}

export default hooks
